-module(session_worker).
-behavior(gen_server).
-export([
    start_link/1, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3,
    map_value/2, map_value/3
]).
-record(state, {storage, path, key, expire}).
-define(COOKIE, #{
    secure => true,
    http_only => true
}).

%API

init([]) -> 
    process_flag(trap_exit, true),
    Storage = config:session(storage),
    Path = config:session(path),
    Key = config:session(key),
    Expire = config:session(expire),
    State = #state{
        storage = Storage, 
        path=Path, 
        key=Key, 
        expire=Expire
    },
    {ok, State}.

-spec map_value(Key::term(), Maps::map()) -> term().
-spec map_value(Key::term(), Maps::map(), Default::term()) -> term().
map_value(K, M) -> map_value(K, M, undefined).
map_value(K, M, D) ->
    case maps:find(K, M) of
        {ok, V} -> V;
        error ->  D
    end.

start_link(Args)-> gen_server:start_link(?MODULE, Args, []).

create_cookie(Req, State) ->
    ID = uid:get_id(),
    K = State#state.key,
    P = State#state.path,
    E = State#state.expire,
    cowboy_req:set_resp_cookie(K, ID, Req, ?COOKIE#{max_age => E, path => P}).

touch_cookie(ID, Req, State) ->
    K = State#state.key,
    E = State#state.expire,
    P = State#state.path,
    cowboy_req:set_resp_cookie(K, ID, Req, ?COOKIE#{max_age => E, path => P }).

handle_call({touch, Req}, _F, State) ->
    K = State#state.key,
    Cookies = cowboy_req:parse_cookies(Req),
    Req1 = case proplists:get_value(K, Cookies) of
        undefined -> create_cookie(Req, State);
        ID -> touch_cookie(ID, Req, State)
    end,
    {reply, Req1, State};

handle_call({get_session, Req}, _F, State) ->
    Key = State#state.key, %?SESSION(key),
    Cookies = cowboy_req:parse_cookies(Req),
    ID = uid:get_id(),
    {SID, Req2} = case proplists:get_value(Key, Cookies) of
        undefined ->
            rand:seed(exsplus),
            Path = State#state.path, %?SESSION(path),
            Expire = State#state.expire, %?SESSION(expire),
            Req1 = cowboy_req:set_resp_cookie(Key, ID, Req, ?COOKIE#{ max_age => Expire, path => Path }),
            io:format(" - Creating new cookies [~p]...~n",[ID]),
            {ID, Req1};
        OID ->
            {OID, Req}
    end,
    
    Storage = State#state.storage, %?SESSION(storage),
    case ets:lookup(Storage, SID) of
        [] -> 
            ets:insert(Storage, {SID, touch()});
        [{_, Session}] -> 
            ets:insert(Storage, {SID, touch(Session)})
    end,
    {reply, {SID, Req2}, State};


handle_call({get, SID}, _F, S) ->
    {reply, get_all(SID, S), S};
handle_call({get, Key, SID, Def}, _F, S) ->
    Session = get_all(SID, S),
    V = map_value(Key, Session, Def),
    {reply, V, S};
    
handle_call({set, K, V, SID}, _F, State)->
    Session = get_all(SID, State),
    Session_1 = Session#{K => V},
    ets:insert(State#state.storage, {SID, Session_1}),
    {reply, Session_1, State};

handle_call({clear, SID}, _, State) ->
    SES = touch(),
    ets:insert(State#state.storage, {SID, SES}),
    {reply, SES, State};

handle_call({delete, K, SID}, _F, State) ->
    Session = get_all(SID, State),
    S1 = touch(maps:remove(K, Session)),
    ets:insert(State#state.storage, {SID, S1}),
    {reply,S1, State}.

get_all(SID, State)->
    case ets:lookup(State#state.storage, SID) of
        [] -> undefined;
        [{_, V}] -> V
    end.

touch() -> touch(#{last_activity => erlang:system_time(seconds)}).
touch(Map)-> Map#{last_activity => erlang:system_time(seconds)}.

handle_cast(_Msg, S)-> {noreply, S}.
handle_info(_Info, S) -> {noreply, S}.
terminate(_Reason, _State) -> ok.
code_change(_OldVsn, S, _Extra) -> {ok, S}.
