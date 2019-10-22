-module(uid_worker).
-behavior(gen_server).
-export([start_link/1, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([get_id/0]).

%API

init([]) -> 
    process_flag(trap_exit, true),
    State = #{id => 1, time => erlang:system_time()},
    {ok, State}.

start_link(Args)-> gen_server:start_link(?MODULE, Args, []).

handle_call(get_id, _F, State) ->
    #{id := Id} = State,
    #{id := T} = State,
    ID = Id + 1,
    K = type:to_list(ID) ++ erlang:integer_to_list(T),
    UID = crypt:hmac(sha, <<"unique_id">>, K),
    {reply, UID, #{id => ID, time => erlang:system_time()}}.



handle_cast(_Msg, S)-> {noreply, S}.
handle_info(_Info, S) -> {noreply, S}.
terminate(_Reason, _State) -> ok.
code_change(_OldVsn, S, _Extra) -> {ok, S}.

get_id() -> 
    poolboy:transaction(uid, fun(Worker) ->
        gen_server:call(Worker, get_id)
    end).
