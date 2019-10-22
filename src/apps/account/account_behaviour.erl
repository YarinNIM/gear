-module(account_behaviour).
-export([handle/4]).

-callback init_action(
    Req :: term(),
    State :: term(),
    Params :: list()
) -> {term(), term(), map()}.


function_exists(M, F) ->
    Exp = proplists:get_value(exports, M:module_info()),
    lists:member({F, 3}, Exp).

handle(Req, State, Params, Module) ->
    #{ extra_param := E, session_id:= Sid} = State,
    {Ctrl_action, Permissions} = case E of
        [] -> {undefined, []};
        {Act, Pers} -> {Act, Pers};
        Else -> {Else, any}
    end,

    Login_ac = session:get(account, Sid),
    #{ id := Aid} = Login_ac,
    Res = case account_model:get_admin_account(Aid) of
        {error, _ } -> {error, <<"Not admin account">>};
        Ac -> 
            validate_permission(Permissions, Ac)
    end,

    case Res of
        ok -> perform(Req, State, Params, Module, Ctrl_action);
        {error, Msg} -> {{halt, Msg}, Req, State}
    end.



validate_permission(Pers, Ac) ->
    case maps:find(is_super_user, Ac) of
        {ok, true} -> ok;
        _ ->
            #{ permissions := Ac_pers} = Ac,
            validate_account_permissions(Pers, Ac_pers)
    end.

validate_account_permissions(any, _) -> ok;
validate_account_permissions(Pers, Ac_pers) ->
    Valid = lists:foldr(fun(Per, S) ->
        In = case maps:find(type:to_binary(Per), Ac_pers) of
            error -> 0;
            {ok, true} -> 1;
            {ok, false} -> 0;
             _ -> 0
        end,
        S + In
    end, 0, Pers),

    if 
        Valid > 0 -> ok;
        true -> {error, <<"Invalid Permission">>}
    end.

perform(Req, State, Params, M, A) ->
    Action = type:to_atom(type:to_list(A) ++ "_action"),
    #{ session_id := Sid}= State,
    Aid = session:get(account_id, Sid),
    case function_exists(M, Action) of
        true -> M:Action(Req, State#{account_id => Aid}, Params);
        _ -> %Req1 = cowboy_req:reply(404, #{ <<"msg">> => <<"Method does not exists">>}, Req),
             {{halt, <<"Method does not exists">>}, Req, State}
    end.
