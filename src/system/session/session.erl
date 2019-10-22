-module(session).

% Supervisor 
-behavior(supervisor).
-export([start/0, start_link/0, init/1]).
-define(WORKER, session_worker).
-define(SERVER, ?MODULE).
-define(VAL(K, L), proplists:get_value(K, L)).
-define(SID(M), maps:get(session_id, M)).

%API
-export([
    init_storage/0, get_all/1,
    get/1, get/2, get/3,
    set/3, clear/1, delete/2,
    restart_pool/0,get_session/1,
    touch/1
]).

-spec start() -> ok.
start()-> 
    init_storage(),
    start_link().

start_link() -> 
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([])->
    Flags = {one_for_one, 1000, 3000},
    Pool_args = [
        {name, {local, ?WORKER}},
        {worker_module, ?WORKER},
        {size, 10},
        {max_overflow, 20}],
    Child_specs = poolboy:child_spec(?WORKER, Pool_args,[]),
    {ok, {Flags,[Child_specs]}}.

init_storage()->
    Storage = config:session(storage),
    io:format('Initializing SESSION [~p]...~n', [Storage]),
    case ets:info(Storage) of
        undefined -> ets:new(Storage, [named_table, set, public]);
        _ -> ok
    end.

get_all(State) when is_map(State) -> get_all(?SID(State));
get_all(SID) ->
    poolboy:transaction(?WORKER, fun (Worker)->
        gen_server:call(Worker, {get, SID})
    end).

get(State) when is_map(State) -> session:get(?SID(State));
get(SID) -> get_all(SID).

get(K, S) -> get(K, S, undefined).
get(K, State, D) when is_map(State) -> session:get(K, ?SID(State), D);
get(K, SID, Def) ->
    poolboy:transaction(?WORKER, fun(Worker) ->
        gen_server:call(Worker, {get, K, SID, Def})
    end).

get_session(Req) ->
    poolboy:transaction(?WORKER, fun(Worker) ->
        gen_server:call(Worker, {get_session, Req})
    end).

set(K, V, State) when is_map(State) -> set(K, V, ?SID(State));
set(K, V, SID) ->
    poolboy:transaction(?WORKER, fun(Worker) ->
        gen_server:call(Worker, {set, K, V, SID})
    end).

clear(State) when is_map(State) -> clear(?SID(State));
clear(SID) ->
    poolboy:transaction(?WORKER, fun(Worker) ->
        gen_server:call(Worker, {clear, SID})
    end).

delete(K, State) when is_map(State) -> delete(K, ?SID(State));
delete(K, SID) ->
    poolboy:transaction(?WORKER, fun(Worker) ->
        gen_server:call(Worker, {delete, K, SID})
    end).


touch(Req) ->
    poolboy:transaction(?WORKER, fun(Worker) ->
        gen_server:call(Worker, {touch, Req})
    end).

restart_pool()->
    supervisor:terminate_child(?SERVER, ?WORKER),
    supervisor:restart_child(?SERVER, ?WORKER).


