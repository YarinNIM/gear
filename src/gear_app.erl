%% @author Yarin NIM, <yarin.nim@gmail.com>
%% @version 0.1
%% @copyright 2019


-module(gear_app).
-behaviour(application).
-define(HANDLER, toppage_handler).

%% API.
-export([
    start/2, stop/1,
    on_sync/1
]).

%% @doc Start the application
start(_Type, _Args) ->
    Dispatch = router:dispatch(),
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
        on_sync(Mods)
    end),
    gear_sup:start_link().

%% Stop the systatem
stop(_State) -> ok.

%% Generate the module when a module is compiled and loaded
%% @todo Will defined what functions will be run automatically
on_sync([Module|_]) ->
    io:format(' - Module reloaded [~p] ...~n',[Module]),
    Found = lists:filter(fun(Item) ->
        Item =:= Module
    end, maps:keys(config:app())),
    case Found of 
        [] -> ok;
        _ -> router:reload()
    end.
