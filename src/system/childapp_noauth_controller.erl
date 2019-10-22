-module(childapp_noauth_controller).
-export([
    login_action/3
]).

login_action(Req, State, _) ->
    #{ session_id := SID} = State,
    Res = case session:get(login, SID) of
        true  -> {redirect, config:base_url(State)};
        _ -> {redirect, config:parent_url(State)}
    end,
    {Res, Req, State}.
