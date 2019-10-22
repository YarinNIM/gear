-module(account_register_controller).
-define(BD_KEYS, [bd_day, bd_month, bd_year]).
-export([
    render_action/3, register_action/3,
    render_verify_action/3, resend_verification_action/3
]).

render_action(Req, State, _) ->
    Res = resource:render_page(#{
        js =>[ 
            {index, config:base_url(<<"js/register.js">>, State)},
            {local, config:locale_url(<<"register">>, State)}
        ],
        on_script_loaded => [<<"_.Register.init();">>]
    }, Req, State),
    {Res, Req, State}.

render_verify_action(Req, State, _Params) ->
    Res = resource:render_page(#{

    }, Req, State),
    {Res, Req, State}.

validate(Post) ->
    Pwd = proplists:get_value(<<"password">>, Post),
    Rules = #{
        first_name =>{[required], <<"First name is required">>},
        last_name =>{[required], <<"Last name is required">>},
        email => {[required, email], <<"Email address is required">>},
        password => {[required, password], <<"Invalid password">>},
        confirm => {[required, {equal_to, Pwd}], <<"Confirm mismatch">>},
        sex => {[required], <<"Please select sex">>},
        birthdate => {[required, date], <<"Invalid birthdate">>}
    },
    validator:validate(Rules, Post).

register_action(Req, State, __) ->
    #{ body_data:= Post} = State,
    Res = case validate(Post) of
        {error, Msg} -> helper:msg(true, Msg, form);
        Account -> do_register(Account, State)
    end,
    {Res, Req, State}.

do_register(Account, State) ->
    #{ session_id := Sid } = State,
    #{password:= Pwd} = Account,
    Account1 = Account#{
        password => crypt:hmac(Pwd),
        session_id => Sid
    },
    case db:call(fun_account_register,[jsx:encode(Account1), Sid]) of
        {error, Msg} -> #{error=> true, msg=>Msg, type=> server};
        Aid -> 
            send_email(Account1#{id=> Aid}, State),
            #{ error => false, msg=>success, type=>success}
    end.

verify_url(Account, State) ->
    #{ session_id := Sid, id := Aid, password := Pwd } = Account,
    Url = helper:join_list([<<"verify">>, Aid, Pwd, Sid], <<"-">>),
    config:base_url(<<Url/binary, ".html">>, State).



send_email(Account, State) ->
    #{ email := Email} = Account,
    Verify_url = verify_url(Account, State),
    email:send_using_template(#{
      to => Email,
      subject => <<"Verify your email address">>,
      email_content_layout => email_account_verify,
      params => Account#{
            verify_url => Verify_url,
            verify_button => template:render(button, #{ text => <<"Verify Email">>, href => Verify_url})
        }
    }).

resend_verification_action(Req, State, _) ->
    #{ body_data:= Post} = State, 
    Email = proplists:get_value(<<"email">>, Post),
    Sql = <<"select account.id, account.password, 
        account.verification_code as session_id, email.email
        from account inner join email on account.email_id = email.id
        where email.email = $1">>,
    [Account] = db:query(Sql,[Email]),
    send_email(Account, State),
    Res = #{ error => false, msg=><<"verification_code_sent">>},
    {Res, Req, State}.
