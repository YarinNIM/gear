-module(admin_controller).
-export([handle_action/3]).

function_exists(M, F) ->
    Exp = proplists:get_value(exports, M:module_info()),
    lists:member({F, 3}, Exp).

handle_action(Req, State, Params) ->
    #{ extra_param := E, session_id:= Sid} = State,
    {Module, Action, Perms} = case E of
        {M, A, P} -> {M, A, P};
        Else  -> {Else, any, any}
    end,

    Aid = session:get(account_id, Sid),
    case validate_permission(Aid, Perms) of
        false -> {{401, <<"Invalid permission">>}, Req, State};
        true -> perform(Req, State, Params, Module, Action)
    end.

validate_permission(_, []) -> ok;
validate_permission(_, any) -> ok;
validate_permission(Aid, Perms) ->
    Error = lists:foldr(fun(Perm, I) ->
        case db:call(fun_admin_validate_permission, [Aid, Perm]) of
            {error, _} -> I +1;
            _ -> I
        end
    end, 0, Perms),
    Error == 0.

perform(Req, State, Params, Module, A) ->
    M = type:to_atom(type:to_list(Module) ++ "_controller"),
    Action = type:to_atom(type:to_list(A) ++ "_action"),
    #{ session_id := Sid}= State,
    Aid = session:get(account_id, Sid),
    case function_exists(M, Action) of
        true -> M:Action(Req, State#{account_id => Aid}, Params);
        _ -> {{404, <<"Method does not exist">>}, Req, State}
    end.
