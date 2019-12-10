%% @author Yarin NIM, <yarin.nim@gmail.com>
%% @version 0.1
%% @copyright 2019


-module(gear_app).
-behaviour(application).
-define(HANDLER, toppage_handler).

%% API.
-export([start/2, stop/1]).
-export([
    app_static/1,
    sub_apps/1, sub_apps/2,
    apps/0, apps_with_domain/1, apps_with_domain/2
]).

map_val(K,M) -> map_val(K,M, undefined).
map_val(K,M, D) ->
    case maps:find(K, M) of
        error -> D;
        {ok, V} -> V
    end.

%% Get the static application configuration
%% including sub application static route
app_static(App) ->
    {Location, Dirs} = config:app(App, static, {<<"">>, []}),
    [{<<"/", Dir/binary, "/[...]">>, cowboy_static, {dir, <<Location/binary, "/", Dir/binary>>}} || Dir <- Dirs] ++
    [{ <<"/favicon.ico">>, cowboy_static, {file, <<Location/binary, "favicon.icon">>}}].

%% @doc Get sub applications and add to the handler
sub_apps(App) ->
    Sub = config:app(App, sub_apps, []),
    sub_apps(Sub, []).
sub_apps([], Apps) -> Apps;
sub_apps([{Prefix, App} | T], Apps) ->
    Base = type:to_binary("/" ++ type:to_list(Prefix) ++ "/"),
    Pref1 = type:to_list(Prefix),
    %Static = sub_static({Prefix, App}),
    %Apps1 = Apps ++ Static ++ [
    Apps1 = Apps ++ [
        {<<Base/binary, "[...]">>, ?HANDLER, [{app, App}, {prefix, Pref1}]}
    ], sub_apps(T, Apps1).
    
apps_with_domain(Apps) -> apps_with_domain(Apps, []).
apps_with_domain([], Apps) -> Apps;
apps_with_domain([App = {_, Conf} | T], Apps_wd) ->
    case map_val(domain, Conf) of
        undefined -> apps_with_domain(T, Apps_wd);
        _ -> apps_with_domain(T, Apps_wd ++ [App])
    end.

apps() ->
    Apps = maps:to_list(config:app()),
    Apps_wd = apps_with_domain(Apps),
    lists:map(fun({App, _}) ->
        Domain = config:app(App, domain),
        Path = [{"/", ?HANDLER, [{app, App}]}]
            ++ app_static(App)
            ++ sub_apps(App)
            ++ [{"/[...]", ?HANDLER, [{app, App}]}],
        {Domain, Path}
    end, Apps_wd).

%% @doc Return the dispatch configuretion
%% and compile, 
get_dispatch() -> 
    Apps = apps(),
    cowboy_router:compile(Apps).

%% @doc Start the application
start(_Type, _Args) ->
    Dispatch = get_dispatch(),
    Protocol = config:server(protocol),
    Opts = #{
        env => #{dispatch =>  Dispatch},
        %stream_handlers =>[cowboy_compress_h, cowboy_stream_h],
        middlewares => [cowboy_router, gear_middleware, cowboy_handler]
    },

    io:format(' - Starting Cowboy ~p server...~n', [Protocol]),
    Conf = config:server(config),

    %% Force get it stated successfully
    {ok, _}  = case Protocol of
        https -> cowboy:start_tls(gear_https, Conf, Opts);
        _ -> cowboy:start_clear(gear_http, Conf, Opts)
    end,

    pg2:create(gear), 
    app_supervisor:start(),
    session:start(), 
    router:start(),
    db:start(),
    event_dispatcher:start(),

    sync:onsync(fun(Mods) ->
        io:format(" - Reloaded Modules: ~p~n",[Mods]) 
    end),

    gear_sup:start_link().

stop(_State) -> ok.
