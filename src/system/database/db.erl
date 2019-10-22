-module(db).
-behaviour(supervisor).

-export([start/0, start/2, start_link/0,init/1]).
-export([send_query/1, send_query/2, send_query/3]).
-export([stop_pool/0, restart_pool/0]).
-export([
    execute/1, execute/2, execute/3,
    execute_async/1, execute_async/2, execute_async/3,

    insert/2, insert/3,
    query/1, query/2, query/3,
    query_row/1, query_row/2, query_row/3,
    call/2, call/3, call_async/1, call_async/2, call_async/3,
    column_info/1, column_info/2,
    error_msg/1
]).

% -export([cast_query/1, cast_query/2, cast_query/3]).

-define(SERVER, ?MODULE).
-define(WORKER, db_worker). 

map_val(K, M) -> map_val(K, M, undefined).
map_val(K, M, D) ->
    case maps:find(K, M) of
        error -> D;
        {ok, V} -> V
    end.
start() ->
    io:format(' - Starting Database connection pool...~n'),
    start_link().

start(_Type, _Args) ->
    start_link().

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    DBs = maps:to_list(config:db()),
    Pool_specs = lists:map(fun({Name, Db_conf}) ->
        #{size := Size } = Db_conf,
        #{max_overflow := MO} = Db_conf,
        Pool_arg = [
            {name, {local, Name}},
            {worker_module, ?WORKER},
            {size, Size},
            {max_overflow, MO}
        ],
        poolboy:child_spec(Name, Pool_arg, Db_conf)
    end, DBs),

    %io:format('=== PGSPL Childspec==~n~p~n===========~n',[Pool_specs]),

    {ok, {{one_for_one, 10, 10}, Pool_specs}}.


send_query(Q) -> send_query(Q, []).
send_query(Q, P) when is_atom(P) -> send_query(Q, [], P);
send_query(Q, P) -> send_query(Q, P, config:db_default_pool()).
send_query(QueryName, Params, Pool) ->
    poolboy:transaction(Pool, fun(Worker)->
        gen_server:call(Worker, {QueryName, Params})
    end).

execute(Q) -> execute(Q,[]).
execute(Q, P) when is_atom(P) -> execute(Q, [], P);
execute(Q, P) -> execute(Q, P, config:db_default_pool()).
execute(Q, P, Pool) ->
    poolboy:transaction(Pool, fun(Worker) ->
        gen_server:call(Worker, {equery, Q, P})
    end).

execute_async(Q) -> execute_async(Q,[]).
execute_async(Q, P) when is_atom(P) -> execute_async(Q, [], P);
execute_async(Q, P) -> execute_async(Q, P, config:db_default_pool()).
execute_async(Q, P, Pool) -> 
    poolboy:transaction(Pool, fun(Worker) ->
        gen_server:cast(Worker, {execute, Q, P})
    end).

query(M) when is_map(M) -> query(M, config:db_default_pool());
query(Q) -> execute(Q, []).
query(M, P) when is_map(M) ->
    {Query, Binded} = db_query_builder:query(M),
    execute(Query, Binded, P);
query(Q, P) when is_atom(P) -> query(Q, [], P);
query(Q, P) ->
    execute(Q, P, config:db_default_pool()).
query(Q, P, Pool) -> 
    execute(Q, P, Pool).

query_row(Q) -> query_row(Q,[]).
query_row(Q, P) -> query_row(Q, P, config:db_default_pool()).
query_row(Q, P, Pl) -> 
    poolboy:transaction(Pl, fun(Wk) ->
        gen_server:call(Wk, {query_row, Q, P})
    end).
    


%% @doc Insert data into a table
-spec insert(Table::string(), Data::map(), Options::map()) -> term().
insert(Table, Data) -> insert(Table, Data, #{}).
insert(Table, Data, Options) -> 
    Pool = map_val(pool,Options, config:db_default_pool()),

    %Cols_info = column_info(Table, Pool),

    Ren = map_val(return_field, Options),
    poolboy:transaction(Pool, fun(Worker) ->
        gen_server:call(Worker, {insert, Table, Data, Ren})
    end).

%% @doc execute all database function
-spec call(Fun_name::atom(), Params::list()) -> { error, Msg::binary()} | term().
call(F, P) -> call(F, P, config:db_default_pool()).
call(Fun, Params, Pool) ->
    F_name = type:to_binary(Fun),
    Binds = db_query_builder:params_to_binded(Params),
    Sql = <<"select * from ", F_name/binary, "(",Binds/binary, ") return_me">>,
    case db:query(Sql, Params, Pool) of
        {error, Msg} -> {error, Msg};
        [Res] -> 
            #{ return_me := Re} = Res,
            Re
    end.

%% @doc Call stored procedure in asyncronouse
-spec call_async(store_procedure:atom(), params:list(), pool:atom()) -> ok.
call_async(F) -> call_async(F,[]).
call_async(F, P) when is_atom(P) -> call_async(F, [], P);
call_async(F, P) -> call_async(F, P, config:db_default_pool()).
call_async(F, P, Pool) -> 
    poolboy:transaction(Pool, fun(Worker) ->
        gen_server:cast(Worker, {call, F, P})
    end).

%% @doc Describes table structure
%% and columns of tables
column_info(Table) -> column_info(Table, config:db_default_pool()).
column_info(Table, Pool) ->
    poolboy:transaction(Pool, fun(Worker) ->
        gen_server:call(Worker, {column_info, Table})
    end).

error_msg(Db) ->
    #{msg := Error_msg} = Db,
    Error_msg.


stop_pool()->
    supervisor:terminate_child(?SERVER, ?WORKER),
    supervisor:delete_child(?SERVER, ?WORKER).

restart_pool()->
    supervisor:restart_child(?SERVER, main),
    supervisor:restart_child(?SERVER, log).
