-module(router_worker).
-behavior(gen_server).
-export([
    start_link/1, init/1, 
    handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3
]).
-define(VAL(K, P), proplists:get_value(K, P)).

-type handler():: atom() | { atom(), atom() }.
-type route_type() ::
    { URL::binary(), HTTP_method::atom(), Handler::handler() | tuple() } | 
    { URL::binary(), HTTP_method::atom(), Handler::handler(), Extra_paramter::any() }.

init([]) -> 
    process_flag(trap_exit, true),
    {ok, []}.

start_link(Args) -> 
    gen_server:start_link(?MODULE, Args, []).
    
-spec route(Route :: route_type()) -> route_type().
route({U, M, H}) -> route({U, M, H,[]});
route({U, _, H, E}) -> 
    Url = type:to_binary(U),
    Url1 = iolist_to_binary(re:replace(Url, <<"\\[number\\]">>,<<"(\\\\d+)">>,[global])),
    Url2 = iolist_to_binary(re:replace(Url1,<<"\\[string\\]">>,<<"([a-zA-Z0-9%\\\\_]+)">>,[global])),
    Url_reg = <<"^",Url2/binary,"$">>,
    {U, Url_reg, H, E}.

route_method({_, M, _}) -> M;
route_method({_, M, _, _}) -> M.

%% @doc Returns the application routes
%% but added the route with regular expression
get_routes(Req, App) -> 
    M = cowboy_req:method(Req),
    Method = type:to_atom(string:to_lower(type:to_list(M))),
    Routes = App:routes(),
    [route(Route) || Route <- Routes, route_method(Route) == Method].


%% @doc Returns the handler with binded parameter.
%% It checks if the requested URL matches the assigned/registered
%% routes of application route list. If no URL match will return no_url
-spec handle_call({resource_exists, Cowboy_req::map(), App_option::map()}, _, State::map()) ->
    no_url | {Controller::atom(), Action::atom(), Binded_params::list(), Extra_url_params::any()}.
handle_call({resource_exists, Req, App_opts}, _From, State) ->
    App = proplists:get_value(app, App_opts),
    %Path = router:request_url(Req, App_opts),
    Path = router:request_url(Req, App_opts),
    Routes = get_routes(Req, App),
    Res = case match_route(Path, Routes) of
        nomatch -> no_url;
        {Url, URL_reg, Handler, E} -> 
            case get_handler(Handler) of
                {C, A} ->
                    P = get_matched_params(Path, URL_reg),
                    Params = get_bind(Url, P),
                    {C, A, Params, E};
                Error -> Error
            end
    end,
    {reply, Res, State}.

% @doc This function loop the list and return, if the 
%   request url matches routes
-spec match_route( Request_url :: binary(), Routes :: [route_type()]) -> 
    [] | [{binary(), binary(), binary()}].

%% Search the URL from route list, if the url exists,
%% it will return the handler
match_route(_,[]) -> nomatch;
match_route(Url, [H | T]) ->
    {_, Url_reg, _, _} = H,
    case re:run(Url, Url_reg, [global, {capture, all, binary}]) of
        nomatch -> match_route(Url, T);
        {match, _} -> H
    end.


%% ===================================================
%% @doc return the paramater passed in the request url
%% ===================================================

-spec get_matched_params(
    Request_url :: binary(),
    Reg_url :: binary()
) -> [] | list().

get_matched_params(RUrl, RegUrl)->
    {_, [[_ | Params]]} = re:run(RUrl, RegUrl, [global, {capture, all, binary}]),
    Params.

%% @doc Validates if the really exists or not
%% @returns welcome
%%  {module_controller, method_action} if valid
%%  no_controller: When module_controller not found
%%  no_action: module_controller exists but there is no method_action method
-spec get_handler(Handlder :: binary()) -> {atom(), atom()}.
get_handler(Handler) ->
    {C, A} = map_handler(Handler),
    try C:module_info() of Module_info -> 
        Exports = proplists:get_value(exports, Module_info),
        case proplists:get_value(A, Exports) of
            undefined -> no_action;
            _ -> {C, A}
        end
    catch 
        _:_ -> no_controller
    end.

%% @doc Maps the handler@acount 
%% into {handler_controller, method_action}
map_handler({C, A}) -> 
    C1 = type:to_list(C) ++ "_controller",
    A1 = type:to_list(A) ++ "_action",
    { type:to_atom(C1), type:to_atom(A1)};
map_handler(C) when is_atom(C)-> map_handler({C, index}).

%% @doc get the bind params in url of binary() 
%% and conver to the type maped in the URL registered
%% in routes
%%
%% @param
%% router_url: The url registered in the route
%% params: The list of parameter as binary
-spec get_bind(Route_url :: binary(), Params :: [binary()]) -> term().
get_bind(Route_url, P) ->
    case re:run(Route_url, <<"string|number">>, [global, {capture, all, binary}]) of
        nomatch -> [];
        {_, Re} -> 
            Bind = [ Item || [Item] <- Re],
            L = lists:zip(Bind, P),
            [ convert(I) || I <- L]
    end.

%% @doc Coverts to number if the binded param 
%% defined as number in url of routers
convert({<<"number">>, V}) -> binary_to_integer(V);
convert({_, V}) -> V.

%------------------------------
% Implement the gen sever
% ---------------

handle_cast(_, S) -> {noreply, S}.
handle_info(_, S) -> {noreply, S}.
terminate(_, _) -> ok.
code_change(_Ov, S,_Extra) -> {ok, S}.
