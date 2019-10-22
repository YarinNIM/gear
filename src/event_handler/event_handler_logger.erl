-module(event_handler_logger).
-behaviour(gen_event).
-define(DB_POOL,log). 
-record(state, {param}).
-export([
    init/1, handle_event/2, handle_call/2, handle_info/2, 
    code_change/3, terminate/2
]).

-export([account_login/1]).

post(F, State) ->
    #{body_data := Post} = State,
    proplists:get_value(F, Post).

init(Arg) -> 
    io:format('Registerering me as : ~p~n',[Arg]),
    {ok, #state{param = Arg}}.

handle_event({account_login, {Req, St, Status}}, State) -> 
    Email = post(<<"email">>, St),
    Ua = cowboy_req:header(<<"user-agent">>, Req),
    Sql = <<"insert into account_login(email, user_agent, success) values($1,$2,$3)">>,
    db:query(Sql, [Email, Ua, Status], log),
    {ok, State};

handle_event({account_login, _Msg}, State) ->
    io:format("Account login triggered"),
    {ok, State};

handle_event(_Msg, State) -> {ok, State}.


handle_call(_, State) -> 
    {ok, ok, State}.
handle_info(_, State) -> 
    {ok, State}.

code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_Reason, _State) -> ok.


account_login(P) -> io:format('Props: ~p~n',[P]).
    %#{email := E} = P,
    %#{password := P} = P,
    %#{session_id := Sid} = P,
    %#{status := St} = P
