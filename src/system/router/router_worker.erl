-module(router_worker).
-behavior(gen_server).
-export([
    start_link/1, init/1, 
    handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3
]).
-define(VAL(K, P), proplists:get_value(K, P)).

init([]) -> 
    process_flag(trap_exit, true),
    {ok, []}.

start_link(Args) -> 
    gen_server:start_link(?MODULE, Args, []).
    
%% @doc This is to check if the quest has handler or not
handle_call({resource_exists, Req, App_opts}, _From, State) ->
    Method = route_method(Req),
    #{ handler := Handlers} = App_opts,
    #{ Method := Handler } = Handlers,
    io:format(' - Handler: ~p...~n', [Handler]),
    Res = check_handler(Handler),
    {reply, Res, State}.

route_method(Req) ->
    Method = cowboy_req:method(Req),
    type:to_atom(string:to_lower(type:to_list(Method))).


%% @doc Validates if the really exists or not
check_handler(Handler = {Controller, Action, _}) ->
    try Controller:module_info() of Module_info -> 
        Exports = proplists:get_value(exports, Module_info),
        case proplists:get_value(Action, Exports) of
            undefined -> {error, no_action};
            _ ->  Handler
        end
    catch 
        _:_ -> {error, no_controller}
    end.

%------------------------------
% Implement the gen sever
% ---------------

handle_cast(_, S) -> {noreply, S}.
handle_info(_, S) -> {noreply, S}.
terminate(_, _) -> ok.
code_change(_Ov, S,_Extra) -> {ok, S}.
