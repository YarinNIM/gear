-module(account_controller).
-export([
    get_accounts_action/3, get_list_action/3,
    get_login_company_account_action/3, logout_action/3,

    insert_account_action/3,
    update_account_action/3,
    update_field_action/3, change_pwd_action/3,
    active_account_action/3
]).

%% Get the active account information.
%% Active account is the account being logged in.
active_account_action(Req, State, _) ->
    Aid = eauth:get_account_id(State),
    Res = #{
      account=> account_model:get_account(Aid),
      error => false
     },
    {Res, Req, State}.


get_login_company_account_action(Req, State, _) ->
    #{ session_id:= Sid} = State,
    #{ account_id:= Aid, company_id:= Cid}= session:get(Sid),
    Res = #{
        error => false,
        account => company_account_model:get_account(Cid, Aid)
    },
    {Res, Req, State}.
    

get_accounts_action(Req, State, _) ->
    Qs = cowboy_req:parse_qs(Req),
    Res = #{
        accounts => account_model:get_accounts(Qs)
    },
    {Res, Req, State}.

get_ref(Req, State) ->
    #{ ref:= Ref } = cowboy_req:match_qs([{ref, [], false}], Req),
    case Ref of
        false -> config:parent_url(State);
        _ -> Ref
    end.

logout_action(Req, State, _) ->
    eauth:logout(State),
    Res = {redirect, get_ref(Req, State)},
    {Res, Req, State}.

validate(Post) ->
    case validator:validate(#{
        id => {[integer], <<"Please provide account id">>},
        first_name => {[required, {minlength, 2}], <<"First name is required">>},
        last_name => {[required, {minlength, 2}], <<"Last name is required">>},
        % phone => {[required, phone, digit_only], <<"Phone is required">>},
        % phone_country_id => {[integer], <<"Select country">>},
        sex => {[required], <<"Please select sex">>},
        birthdate =>  {[date_time], <<"Birthdate is required">>}
    },Post) of
        {error, Msg} -> {error, Msg};
        Valid -> 
            Valid#{
                email => proplists:get_value(<<"email">>, Post),
                about => proplists:get_value(<<"about">>, Post)
            }
    end.

insert_account_action(Req, State, _) ->
    #{body_data:= Post, account_id:= Aid} = State,
    Res = case validate(Post) of
        {error, Msg} -> helper:msg(true, Msg, form);
        Account -> case account_model:insert_account(Account, Aid) of
            {error, Db} -> helper:msg(true, Db, server);
            Id -> 
                #{
                    error => false,
                    account => account_model:get_account(Id)
                }
            end
    end,
    {Res, Req, State}.


update_account_action(Req, State, _) ->
    #{body_data := Post, account_id:= Aid} = State,
    Res = case validate(Post) of
        {error, Msg} -> helper:msg(true, Msg, form);
        Ac -> 
            io:format('BD: ~p~n',[Ac]),
            #{id:= Ac_id} = Ac,
            case account_model:update_account(Ac_id, Ac, Aid) of
                {error, Db} -> {true, Db, server};
                _ ->
                    #{ 
                    error => false,
                    account => account_model:get_account(Ac_id)
                    }
            end
    end,
    {Res, Req, State}.

validate_field(Field, Post) ->
    F1 = type:to_atom(Field),
    validator:validate(#{
        field_value => {[F1, required], <<"Invalid ", Field/binary>>},
        id => {[int], <<"">>}
    }, Post).

update_field_action(Req, State, _) ->
    #{ body_data:= Post} = State,
    Field = proplists:get_value(<<"field">>, Post),
    Res = case validate_field(Field, Post) of
        {error, #{field_value := Msg}} -> 
            helper:msg(true, Msg, form);
        P -> 
            #{id:= Ac_id, field_value := Val} = P,
            Res1 = case Field of
                <<"phone">> ->
                    Val1 = re:replace(Val, <<"\\s*">>, <<>>, [global, {return, binary}]),
                    account_model:update_phone(Ac_id, Val1);
                <<"email">> ->
                    Val1 = string:lowercase(Val),
                    Val2 = re:replace(Val1, <<"\\s*">>, <<>>, [global, {return, binary}]),
                    account_model:update_email(Ac_id, Val2);
                <<"status">> -> 
                    account_model:update_status(Ac_id, Val)
            end,
            case Res1 of
                {error, Db} -> helper:msg(true, Db, server);
                _ ->
                    #{
                        error => false,
                        account => account_model:get_account(Ac_id)
                    }
            end
    end,
    {Res, Req, State}.

get_list_action(Req, State, _) ->
    #{q:= Q, limit:= L} = cowboy_req:match_qs([{limit, int}, {q, [], <<"">>}], Req),
    Res = #{
        error => false,
        accounts => account_model:filter_accounts(Q, L)
    },
    {Res, Req, State}.

change_pwd_validate(Post) ->
    Pwd = proplists:get_value(<<"password">>, Post),
    validator:validate(#{
        cur_pwd =>  {[required], <<"Password is required">>},
        password => {[required, password], <<"A valid new password is required">>},
        confirm => {[{equal_to, Pwd}], <<"Confirm mismatch">>}
    }, Post).

%% Change password using PUT method
change_pwd_action(Req, State, _) ->
    #{body_data:= Post} = State,
    Res = case change_pwd_validate(Post) of
        {error, Msg} -> helper:msg(true, Msg);
        #{cur_pwd:= Old, password:= Pwd} = _Data ->
            #{account_id:= Aid} = State,
            case account_model:change_password(Aid, Old, Pwd) of
                0 ->  helper:msg(true, <<"Invalid old password">>, server);
                _ -> helper:msg(false, <<"Pwd changed">>)
            end
    end,
    {Res, Req, State}.
