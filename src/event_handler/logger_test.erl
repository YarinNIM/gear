-module(logger_test).
-behavior(gen_event).
-record(state, {param}).

-export([
    start_link/2, init/1,
    handle_event/2, handle_call/2
]).


start_link(E, _) -> 
    io:format('Stat_link...~n'),
    process_flag(trap_exit, true),
    gen_event:start_link({local, E}).

init(Arg) -> {ok, #state{param = Arg}}.



handle_event({account_login, Msg}, St) ->
    io:format('New Message from account login: ~p~n',[Msg]),
    {ok, St}.

handle_call(_, S) -> {ok, ok, S}.
