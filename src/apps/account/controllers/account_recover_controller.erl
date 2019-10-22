-module(account_recover_controller).
-define(V(K, L), proplists:get_value(K, L)).
-define(V(K,L, D), proplists:get_value(K, L, D)).
-export([
    render_recover_action/3,
    recover_pwd_action/3,
    reset_password_action/3
]).



validate(Post) -> validator:validate(#{ email => {[email, required], <<"Invalid email format">>} }, Post).
get_account(Id) ->
    Sql = <<"select id, password as pwd, verification_code as sid
    from account where id = $1 limit 1">>,
    [Ac] = db:query(Sql, [Id]),
    Ac.


recover_pwd_action(Req, State, _) ->
    #{ body_data:= Post} = State,
    Res = case validate(Post) of
        {error, Msg} -> helper:msg(true, Msg, form);
        Data -> 
            #{email := Email} = Data,
            case  db:call(fun_account_recover_password,[Email]) of
                {error, Db} -> helper:msg(true, Db, server);
                Aid -> send_recover_code(Aid, Email, State)
            end
    end,
    {Res, Req, State}.


send_recover_code(Aid, Email, State)  ->
    Ac = get_account(Aid),
    Url = url(Ac, State),
    email:send_using_template(#{
          to => Email,
          subject => <<"Reset my password">>,
          email_content_layout => email_account_reset_pwd,
          params => Ac#{url => Url}
    }),
    #{error => false, msg=><<"Recover password code sent">>}.



url(Ac, State) ->
    #{ id:= Id, pwd:= Pwd, sid:= Sid} = Ac,
    Url = helper:join_list([<<"recover_pwd">>, Id, Pwd, Sid],<<"-">>),
    config:base_url(<<Url/binary,".html">>, State).


render_recover_action(Req, State, Params) ->
    Res = case validate_reset_pwd_code(Params) of
        {error, _}-> {redirect, config:base_url(State)};
        _ -> render(Params, Req, State)
    end,
    {Res, Req, State}.

render([Aid, Pwd, Sid], Req, State) ->
    Id = type:to_binary(Aid),
    Params = <<"(",Id/binary, ", '", Pwd/binary,"', '", Sid/binary,"')">>,
    resource:render_page(#{
        js => [
            {locale, config:locale_url(<<"login">>, State)},
            {reset, config:base_url(<<"js/recover_pwd.js">>, State)}
        ],
        on_script_loaded => [<<"_.RecoverPwd.init", Params/binary>>]
    }, Req, State).


validate_reset(Post) ->
    Pwd = proplists:get_value(<<"password">>, Post),
    validator:validate(#{
        password => {[required, password], <<"Invalid password format">>},
        confirm => {[required, {equal_to,Pwd}], <<"Confirm does not match">>},
        id => {[int], <<>>},
        sid => {[required], <<>>},
        pwd => {[required], <<>>}
    }, Post).

reset_password_action(Req, State, _) ->
    #{ body_data:= Post} = State,
    Res = case validate_reset(Post) of
        {error, Msg} -> helper:msg(error, Msg, form);
        Data ->
            #{ id:= Id, password:= Pwd} = Data,
            Data1 = Data#{ password => crypt:hmac(Pwd)},
            case db:call(fun_account_reset_password,[Id, jsx:encode(Data1)]) of
                {error, Db}-> helper:msg(true, Db, server);
                _ -> #{
                    error => false,
                    account_id => Id,
                    msg => <<"Reset successfully">>
                }
            end
    end,
    {Res, Req, State}.

validate_reset_pwd_code(Params) ->
    Sql = <<"select id from account 
        where id = $1 and password = $2 and verification_code = $3
        and status = true and verified = true">>,
    case db:query(Sql, Params) of
        {error, Db} ->{error, Db};
        [] -> {error, <<"Invalid reset password code">>};
        [_] -> Params
    end.
