%% @author Yarin NIM, <yarin.nim@gmail.com>
%% @copyright yarin@2020
%% @doc Router

-module(router).
-behavior(supervisor).
-export([init/1, start/0]).
-define(WORKER, router_worker).
-define(SERVER, ?MODULE).
-define(VAL(K, P), proplists:get_value(K, P)).

-export([
     resource_exists/2, children/0,
     request_url/2, 
     static_routes/1,
     routes/0, dispatch/0, reload/0
]).

start() ->
    io:format(' - Starting routing server...~n'),
    start_link().

start_link() -> 
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

static_routes(App) -> route_helper:static_routes(App).
routes() -> route_helper:routes().
dispatch()-> route_helper:dispatch().
reload()-> route_helper:reload().

%% Reload the routes configraion
%% reload() -> cowboy:set_env(gear_system, dispatch,

%% Gen Server initialization
init([]) ->
    Flags = {one_for_one, 10, 10},
    Apps = maps:to_list(config:app()),
    Pool_specs = lists:map(fun({Name, _App_conf}) ->
        Pool_arg = [
            {name, {local,Name}},
            {worker_module, ?WORKER},
            {size, 10},
            {max_overflow, 20}
        ],
        poolboy:child_spec(Name, Pool_arg, [])
    end, Apps),
    {ok, {Flags, Pool_specs}}.

request_url(Req, App_opts) ->
    Url = cowboy_req:path(Req),
    case proplists:get_value(prefix, App_opts) of
        undefined -> Url;
        Prefix -> 
            Pre = type:to_binary(Prefix),
            Re = re:replace(Url, <<"^/",Pre/binary>>, <<"">>),
            iolist_to_binary(Re)
    end.


resource_exists(Req, App_info) ->
    App_name = proplists:get_value(app, App_info),
    poolboy:transaction(App_name, fun(Worker) ->
        gen_server:call(Worker, {resource_exists, Req, App_info})
    end).

children() -> supervisor:which_children(?SERVER).
