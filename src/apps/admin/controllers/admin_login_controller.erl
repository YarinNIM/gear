-module(admin_login_controller).
-export([
    render_action/3,
    login_action/3, logout_action/3
]).

render_action(Req, State, _) ->
    Res = resource:render_page(#{
        js => [
            {login, config:base_url(<<"js/login.bundle.js">>, State)}
        ],
        on_script_loaded => [<<"_.initLogin();">>]
     }, Req, State),
    {Res, Req, State}.

login_action(Req, State, _) ->
    Res = gear_account_login:admin_login(State),
    {Res, Req, State}.

logout_action(Req, State, _) ->
    #{ session_id := Sid} = State,
    session:clear(Sid),
    {{redirect, config:base_url(State)}, Req, State}.
