%% @author Yarin NIM <yarin.nim@gmail.com>
%% @copyright 2019 Yarin NIM
%% @version 0.1
%% @title Athenticatoin Library
%% @doc Description about documentation
%%
-module(eauth).
-export([
    attempt/3, check/1,
    get_session_id/1,
    get_account_id/1,
    logout/1
]).

%% @doc Attempt to login, it will return account ID
%% or {error, ErrorMsg}
-spec attempt(binary(), binary(), binary()) -> {error, binary()} | integer().
attempt(Id, Pwd, Sid) ->
    Pwd_h = crypt:hash(Pwd),
    case db:call(fun_account_login, [Id, Pwd_h]) of
        {error, Msg} -> {error, Msg};
        Aid ->
            Ac = account_model:get_account(Aid),
            session:set(account_id, Aid, Sid),
            session:set(has_login, true, Sid),
            session:set(identity, Ac, Sid),
            Aid
    end.

%% @doc Get the account ID of login account
-spec get_account_id(map()) -> integer().
get_account_id(State) ->
    #{account_id:= Aid} = State,
    Aid.
    
%% @doc Return boolean indicates if the account has logged in
-spec check(term()) -> boolean.
check(State) -> session:get(has_login, State, false).

get_session_id(State) -> maps:get(session_id, State).

% @doc Logout the login account and clear session
-spec logout(binary() | map()) -> ok.
logout(State) -> 
    session:clear(State).
    
