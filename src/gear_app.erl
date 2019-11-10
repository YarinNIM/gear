%% 
%% @author Yarin NIM, <yarin.nim@gmail.com>
%% @version 0.1
%% @copyright 2019 welcome
%%
%% fjdsalfjds;laf j

-module(gear_app).
-behaviour(application).
-define(TOPPAGE_HANDLER, toppage_handler).

%% API.
-export([start/2, stop/1]).
-export([
    app_static/1,
    sub_apps/1, sub_apps/2,
    apps/0, apps_with_domain/1, apps_with_domain/2
]).

static_route(Route, Pre) ->
    Prefix = case Pre of
        "" -> "";
        _ -> "/" ++ type:to_list(Pre)
    end,
    [{Prefix ++ P, cowboy_static, Op} || {P, Op } <- Route].

%% @doc Get the static application configuration
%% including sub application static route
app_static(App) ->
    Static = static_route(config:app(App, static), ""),
    Static ++ lists:foldr(fun({Prefix, Sub_app}, Init) ->
        Init ++ static_route(config:app(Sub_app, static), Prefix)
    end, [], config:app(App, sub_apps)).


%% @doc Get sub applications and add to the handler
sub_apps(App) ->
    Sub = config:app(App, sub_apps),
    sub_apps(Sub, []).
sub_apps([], Apps) -> Apps;
sub_apps([{Prefix, App} | T], Apps) ->
    Base = type:to_binary("/" ++ type:to_list(Prefix) ++"/[...]"),
    Pref1 = type:to_list(Prefix),
    %Static = sub_static({Prefix, App}),
    %Apps1 = Apps ++ Static ++ [
    Apps1 = Apps ++ [
        {Base, ?TOPPAGE_HANDLER, [{app, App}, {prefix, Pref1}]}
    ],
    sub_apps(T, Apps1).
    
apps_with_domain(Apps) -> apps_with_domain(Apps, []).
apps_with_domain([], Apps) -> Apps;
apps_with_domain([App = {_, Conf}|T],Apps_wd) ->
    #{domain := Domain} = Conf,
    case Domain of
        undefined -> apps_with_domain(T, Apps_wd);
        _ -> apps_with_domain(T, Apps_wd ++ [App])
    end.

apps() ->
    Apps = maps:to_list(config:app()),
    Apps_wd = apps_with_domain(Apps),
    lists:map(fun({App, _}) ->
        Domain = config:app(App, domain),
        Handler = toppage_handler,
        Static = app_static(App),
        Path = Static ++
            [{"/", Handler, [{app, App}]}] ++
            sub_apps(App) ++
            [{"/[...]", Handler, [{app, App}]}],
        {Domain, Path}
    end, Apps_wd).

static_resource() -> 
    Res = maps:to_list(config:static()),
    lists:map(fun({R, _}) ->
        Domain = config:static(R,domain),
        Path =   config:static(R, path),
        Extra = config:static(R, extra),
        {Domain, [
            {"/", cowboy_static, {file, Path ++ "index.html"}},
            {"/[...]", cowboy_static, {dir, Path, Extra}}
        ]}
    end,Res).

%% @doc Return the dispatch configuretion
%% and compile
get_dispatch() -> 
    Apps = apps(),
    Res = static_resource(),
    cowboy_router:compile(Apps ++ Res).

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
