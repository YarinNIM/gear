-module(cp_behaviour).
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

    Aid = session:get(account_id, Sid),
    Cid = session:get(company_id, Sid),
    Res = case company_account_model:account_permissions(Cid, Aid) of
        {error, Msg } -> {error,  Msg};
        Perms -> validate_permission(Permissions, Perms)
    end,

    case Res of
        ok -> perform(Req, State, Params, Module, Ctrl_action);
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

perform(Req, State, Params, M, A) ->
    Action = type:to_atom(type:to_list(A) ++ "_action"),
    #{ session_id := Sid}= State,
    Aid = session:get(account_id, Sid),
    case function_exists(M, Action) of
        true -> M:Action(Req, State#{account_id => Aid}, Params);
        _ -> %Req1 = cowboy_req:reply(404, #{ <<"msg">> => <<"Method does not exists">>}, Req),
             {{404, <<"Method does not exists">>}, Req, State}
    end.
