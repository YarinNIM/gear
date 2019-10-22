-module(account_login_controller).
-export([
    render_action/3,
    login_action/3
]).

render_action(Req, State, _) ->
    Res = case eauth:check(State) of
        true -> {redirect, config:parent_url(State)};
        false ->
            #{ service:= Serv, ref:= _Ref}  = cowboy_req:match_qs([{service,[], <<"account">>}, {ref,[], <<>>}], Req),
            resource:render_page(#{
                js => [ 
                    config:base_url(<<"js/login.js">>, State),
                    config:locale_url(<<"login">>, State)
                ],
                on_script_loaded => [<<"_.initLogin('", Serv/binary,"');">>]
             }, Req, State)
    end,
    {Res, Req, State}.

login_action(Req, State, _) ->
    #{ body_data := Post, session_id := Sid} = State,
    Pwd = proplists:get_value(<<"password">>, Post, <<"">>),
    Serv = proplists:get_value(<<"service">>, Post, <<"account">>),
    Pwd_h = crypt:hmac(Pwd),
    Email = proplists:get_value(<<"email">>, Post, <<"">>),
    Aid = case Serv of
        <<"admin">> -> db:call(fun_admin_account_login,[Email, Pwd_h]);
        <<"cp">> -> db:call(fun_cp_account_login, [Email, Pwd_h]);
        _ -> db:call(fun_account_login, [Email, Pwd_h])
        %_ -> {error, testing} %account_login(Email, Pwd_h)
    end, 

    case Aid of
        {error, Msg} -> {#{ error => true, msg => Msg, type=> server, email => Email}, Req, State};
        _ -> 
            Ac = account_model:get_account(Aid),
            session:set(account_id, Aid, Sid),
            session:set(has_login, true, Sid),
            Res1 = #{ error => false, account=>Ac, type=>success, service=>Serv},
            Res2 = case Serv of
                <<"cp">> -> Res1#{companies => company_account_model:get_companies(Aid) };
                _ -> Res1
            end,
            {Res2, Req, State}
    end.
    %{Res, Req, State}.

%   case db:call(fun_admin_account_login, [Email, Pwd_h]) of
%       {error, Db} -> #{ error => true, msg => Db};
%       Aid ->
%           Ac = account_model:get_account(Aid),
%           session:set(account_id, Aid, Sid),
%           session:set(has_login, true, Sid),
%           session:set(account, Ac, Sid),
%           #{ error => false, type=>success}
%   end.

