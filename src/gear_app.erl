%% @author Yarin NIM, <yarin.nim@gmail.com>
%% @version 0.1
%% @copyright 2019


-module(gear_app).
-behaviour(application).
-define(HANDLER, toppage_handler).

%% API.
-export([start/2, stop/1]).

%% @doc Return the dispatch configuretion
%% and compile, 
get_dispatch() -> 
    Apps = router:routes(),
    io:format('App: ~p~n',[Apps]),
    cowboy_router:compile(Apps).

%% @doc Start the application
start(_Type, _Args) ->
    Dispatch = get_dispatch(),
    Protocol = config:server(protocol),
    Opts = #{
        env => #{dispatch =>  Dispatch},
        stream_handlers =>[cowboy_compress_h, cowboy_stream_h],
        middlewares => [cowboy_router, gear_middleware, cowboy_handler]
    },

    io:format(' - Starting Cowboy ~p server...~n', [Protocol]),
    Conf = config:server(config),

    %% Force get it stated successfully
    {ok, _}  = case Protocol of
        https -> cowboy:start_tls(gear_system, Conf, Opts);
        _ -> cowboy:start_clear(gear_system, Conf, Opts)
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
