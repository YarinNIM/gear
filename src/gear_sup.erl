%% Feel free to use, reuse and abuse the code in this file.

%% @private
-module(gear_sup).
-behaviour(supervisor).

%% API.
-export([start_link/0]).
-export([stop_pool/0, restart_pool/0]).

%% supervisor.
-export([init/1]).

%% API.

-spec start_link() -> {ok, pid()}.
start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% supervisor.
init([]) ->
    Procs = [],
    {ok, {{one_for_one, 10, 10}, Procs}}.

stop_pool() ->
    supervisor:terminate_child(?MODULE, ?MODULE),
    supervisor:delete_child(?MODULE, ?MODULE).

restart_pool() ->
    supervisor:terminate_child(?MODULE, ?MODULE),
    supervisor:restart_child(?MODULE, ?MODULE).
    
