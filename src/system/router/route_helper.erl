%% @author Yarin NIM <yarin.nim@gmail.com>
%% @copyright yarin.nim@2019
%% @doc This is helper module to support the
%% route configuration and actions.

-module(route_helper).
-define(HANDLER, toppage_handler).
-export([
    static_routes/1,
    routes/0, dispatch/0, reload/0
]).

map_val(K,M) -> map_val(K,M, undefined).
map_val(K,M, D) ->
    case maps:find(K, M) of
        error -> D;
        {ok, V} -> V
    end.

%% Get the static application configuration
%% including sub application static route
static_routes(App) ->
    {Location, Dirs} = config:app(App, static, {<<"">>, []}),
    [{<<"/", Dir/binary, "/[...]">>, cowboy_static, {dir, <<Location/binary, "/", Dir/binary>>}} || Dir <- Dirs] ++
    [{ <<"/favicon.ico">>, cowboy_static, {file, <<Location/binary, "favicon.icon">>}}].


%% @doc Get sub applications and add to the handler
sub_apps(App) ->
    Sub = config:app(App, sub_apps, []),
    sub_apps(Sub, []).
sub_apps([], Apps) -> Apps;
sub_apps([{Prefix, _App} | T], Apps) ->
    _Base = type:to_binary("/" ++ type:to_list(Prefix) ++ "/"),
    _Pref1 = type:to_list(Prefix),
    %Static = sub_static({Prefix, App}),
    %Apps1 = Apps ++ Static ++ [
    Apps1 = Apps ++ [
        %% {<<Base/binary, "[...]">>, ?HANDLER, [{app, App}, {prefix, Pref1}]}
    ], sub_apps(T, Apps1).

%% Get the list of applications which defined 
%% with domain.
with_domain(Apps) -> with_domain(Apps, []).
with_domain([], Apps) -> Apps;
with_domain([App = {_, Conf} | T], Apps_wd) ->
    case map_val(domain, Conf) of
        undefined -> with_domain(T, Apps_wd);
        _ -> with_domain(T, Apps_wd ++ [App])
    end.

%% returns all route list of all applications
routes() ->
    Apps = maps:to_list(config:app()),
    Apps_wd = with_domain(Apps),
    lists:map(fun({App, _}) ->
        Domain = config:app(App, domain),
        Path = app_routes(App)
            ++ static_routes(App)
            ++ sub_apps(App),
            %% ++ [{"/[...]", ?HANDLER, {App, handler}}],
        {Domain, Path}
    end, Apps_wd).

app_routes(App) -> 
    Routes = App:routes(),
    [encode_route(Route, App) || Route <- Routes].

%% Convert method in atom format to binary
allowed_methods(Methods) ->
    [ type:to_binary(string:to_upper(type:to_list(Method))) || Method <- Methods].

encode_route({Url, Opts}, App) ->
    { Url, ?HANDLER, route_options(Opts, App)}.

route_options(Opts, App) -> 
    Methods = maps:keys(Opts),
    #{
        app => App,
        allowed_methods => allowed_methods(Methods),
        handler => route_handlers(Opts)
    }.

route_handlers ( Opts ) ->
    maps:map(fun(_Key, Val) ->
        route_handler(Val)
    end, Opts).

route_handler(Handler) when is_atom(Handler) -> route_handler({Handler, index});
route_handler({Handler, Action}) -> route_handler({Handler, Action, #{}});
route_handler({Controller, Action, Opts}) ->
    {
        type:to_atom(type:to_list(Controller) ++ "_controller"),
        type:to_atom(type:to_list(Action) ++ "_action"),
        Opts
    }.

dispatch() ->
    Routes = router:routes(),
    cowboy_router:compile(Routes).

reload() ->
    io:format(' - Reloading route dispatch...~n'),
    Dispatch = dispatch(),
    cowboy:set_env(gear_system, dispatch, Dispatch).
