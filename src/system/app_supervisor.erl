-module(app_supervisor).
-behaviour(supervisor).
-export([start/0, start/2, start_link/0, init/1]).
-export([
    pgsql_specs/0,
    session_specs/0
]).

start() ->
    io:format(' - Staring application supervisor...~n'),
    start_link().

start(_T, _A) -> start_link().
start_link()->
    supervisor:start_link({local, config:system_sup()}, ?MODULE, []).


init([]) ->
    {ok, {{one_for_one, 10, 10}, 
        uid_spec()
    }}.

pgsql_specs() ->
    Children = maps:to_list(config:db()),
    lists:map(fun({Name, Db_conf}) ->
        #{size := Size } = Db_conf,
        #{max_overflow := MO} = Db_conf,
        Pool_arg = [
            {name, {local, Name}},
            {worker_module, pgsql_worker},
            {size, Size},
            {max_overflow, MO}
        ],
        poolboy:child_spec(Name, Pool_arg, Db_conf)
    end, Children).


session_specs() ->
    %Ses = maps:to_list(config:session()),
    session:init_storage(),
    Pool_args = [
        {name, {local, session}},
        {worker_module, session_worker},
        {size, 10},
        {max_overflow, 20}
    ],
    [poolboy:child_spec(session, Pool_args,[])].

uid_spec() ->
    Pool_arg = [
        {name, {local, uid}},
        {worker_module, uid},
        {size, 10},
        {max_overflow, 20}
    ],
    [poolboy:child_spec(uid, Pool_arg, [])].


