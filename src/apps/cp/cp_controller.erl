-module(cp_controller).
-export([handle_action/3]).

function_exists(M, F) ->
    Exp = proplists:get_value(exports, M:module_info()),
    lists:member({F, 3}, Exp).

handle_action(Req, State, Params) ->
    #{ extra_param := E, session_id:= Sid} = State,
    {Module, Action, Permissions} = case E of
        [] -> {undefined, []};
        {M,  A, Pers} -> {M, A, Pers};
        Else -> {Else, any}
    end,

    Aid = session:get(account_id, Sid),
    Cid = session:get(company_id, Sid),
    Res = case company_account_model:account_permissions(Cid, Aid) of
        {error, Msg } -> {error,  Msg};
        Perms -> validate_permission(Permissions, Perms)
    end,

    case Res of
        ok -> perform(Req, State, Params, Module, Action);
        {error, Error} -> {{halt, Error}, Req, State}
    end.

validate_permission(any, _) -> ok;
validate_permission(Pers, Ac_pers) ->
    Valid = lists:foldr(fun(Per, S) ->
        In = case maps:find(type:to_binary(Per), Ac_pers) of
            {ok, true} -> 1;
            _ -> 0
        end,
        S + In
    end, 0, Pers),

    if 
        Valid > 0 -> ok;
        true -> {error, <<"Invalid Permission">>}
    end.

perform(Req, State, Params, Module, A) ->
    M = type:to_atom(type:to_list(Module) ++ "_controller"),
    Action = type:to_atom(type:to_list(A) ++ "_action"),
    #{ session_id := Sid}= State,
    Aid = session:get(account_id, Sid),
    Cid = session:get(company_id, Sid),
    case function_exists(M, Action) of
        true -> M:Action(Req, State#{account_id => Aid, company_id => Cid}, Params);
        _ -> {{404, <<"Method does not exists">>}, Req, State}
    end.
