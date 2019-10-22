-module(gear_account_register).
-define(BD_KEYS, [<<"bd_day">>, <<"bd_month">>, <<"bd_year">>]).
-define(VAL(K,L), proplists:get_value(K, L)).
-export([
    register_account/2,
    resend_verification_code/1
]).

%% @doc If the validation is invalid
%% it will check if the birthday error,
%% to add the error msg for birthday.
-spec bd_error(list()) -> {error, list()}.
bd_error(Msg) -> 
    Keys = proplists:get_keys(Msg),
    F = lists:foldl(fun(K, Start) ->
        case lists:member(K, Keys) of
            true -> Start + 1;
            _ -> Start
        end
    end, 0, ?BD_KEYS),
    
    Msg_1 = if
        F > 0 -> 
            Msg_t = remove_bd_error(Msg),
            Msg_t ++ [{<<"birthday">>, <<"Invalid birthday">>}];
        true -> Msg
    end,
    {error, Msg_1}.

%% delete bd error mesg
remove_bd_error(Msg) ->
    lists:foldr(fun(Key, In) ->
        proplists:delete(Key, In)
    end, Msg, ?BD_KEYS).


validate(Post) ->
    I_bd = <<"Invalid brithday">>,
    Rules = [
        {<<"first_name">>, [required], <<"First name is required">>},
        {<<"last_name">>, [required], <<"Last name is required">>},
        {<<"email">>, [required, email], <<"Email address is required">>},
        {<<"password">>, [required, password], <<"Invalid password">>},
        {<<"sex">>, [required], <<"Please select sex">>},
        {<<"bd_day">>, [integer, {min, 1}], I_bd},
        {<<"bd_month">>, [integer, {min, 1}], I_bd},
        {<<"bd_year">>, [integer, {min, 1900}], I_bd}
    ],
    case validator:validate(Rules, Post) of
        {error, Msg} -> bd_error(Msg);
        Params -> Params
    end.

do_register([Fname, Lname, Email, Pwd, Sex, Day, Month, Year], State) ->
    #{ session_id := Sid } = State,
    Pwd_1 = crypt:hmac(Pwd),
    Bd = {Year, Month, Day},
    Params = [Email, Pwd_1, Fname, Lname, Sex, Bd, Sid],
    case db:call(fun_account_register,Params) of
        {error, Msg} -> #{error=> true, msg=>Msg, type=> server};
        Aid -> 
            #{ session_id := Sid} = State,
            Info = #{
                account_id => Aid,
                first_name => Fname,
                last_name => Lname,
                email => Email,
                pwd => Pwd_1,
                session_id => Sid
            },
            send_email(Info, State),
            #{ error => false, msg=>success, type=>success}
    end.


verify_url([Aid, Pwd, Sid], State) ->
    Url = helper:join_list([<<"verify">>, Aid, Pwd, Sid], <<"-">>),
    config:base_url(<<Url/binary, ".html">>, State).

send_email(Params, State) ->
    #{ 
        session_id := Sid,
        email := Email,
        account_id := Aid,
        pwd := Pwd
     } = Params,
    Verify_url = verify_url([Aid, Pwd, Sid], State),
    email:send_using_template(#{
      to => Email,
      subject => <<"Verify your email address">>,
      email_content_layout => email_account_verify,
      params => Params#{
            verify_url => Verify_url,
            verify_button => template:render(button, #{ text => <<"Verify Email">>, href => Verify_url})
        }
    }).



register_account(Req, State) ->
    #{ body_data := Post} = State,
    Res = case validate(Post) of
        {error, Msg} -> 
            #{ error => true, msg => Msg, type=> form };
        Params -> 
            do_register(Params, State)
    end,
    {Res, Req, State}.


resend_verification_code(State) ->
    #{ body_data := Post} = State,
    Email = proplists:get_value(<<"email">>, Post, <<"">>),
    Ac = account_model:get_account(Email),
    #{ id := Aid, password := Pwd, verification_code := Vcode} = Ac,
    Params = Ac#{
        session_id => Vcode,
        account_id => Aid,
        pwd => Pwd
    },
    send_email(Params, State).


