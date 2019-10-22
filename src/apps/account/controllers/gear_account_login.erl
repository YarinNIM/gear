-module(gear_account_login).
-export([
    %render_page/2, render_page/3,
    do_login/1
    %admin_login/1
]).

%login_res(State, _Props) ->
%   Def = #{
%       js => [
%           {login, config:base_url("js/login.bundle.js", State)},
%%          {regi_loc, config:locale_url("login", State)}
%       ],
%
%       on_script_loaded => [
%%          <<"_.initLogin();">>
%       ]
%    },
%   Def.
%
%
%render_page(Req, State) -> render_page(Req, State, #{}).
%render_page(Req, State, Props) ->
%   Res = case gear_account:is_login(State) of
%       false -> resource:render_page(login_res(State, Props), Req, State);
%       _ -> {redirect, config:base_url(State)}
%   end,
%   {Res,Req, State}.


do_login(State) ->
    #{ body_data := Post} = State,
    #{ session_id := Sid} = State,
    Pwd = proplists:get_value(<<"password">>, Post, <<"">>),
    Pwd_h = crypt:hmac(Pwd),
    Email = proplists:get_value(<<"email">>, Post, <<"">>),
    case db:call(fun_account_login,[Email, Pwd_h]) of
        {error, Msg} -> {error, Msg};
        Aid ->  
            Ac = account_model:get_account(Aid),
            session:set(has_login, true, Sid),
            session:set(account, Ac, Sid),
            Ac
    end.

%admin_login(State) ->
%   #{ body_data := Post, session_id := Sid} = State,
%   Pwd = proplists:get_value(<<"password">>, Post, <<"">>),
%   Pwd_h = crypt:hmac(Pwd),
%   Email = proplists:get_value(<<"email">>, Post, <<"">>),
%   case db:call(fun_admin_account_login, [Email, Pwd_h]) of
%       {error, Db} -> #{ error => true, msg => Db};
%       Aid ->
%           Ac = account_model:get_account(Aid),
%           session:set(account_id, Aid, Sid),
%           session:set(has_login, true, Sid),
%           session:set(account, Ac, Sid),
%           #{ error => false, type=>success}
%   end.

