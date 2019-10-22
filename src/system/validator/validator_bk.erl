-module(validator_bk).
-export([validate/2, validate_key/3, validate_key/4, get_data/2]).
-define(UD, uploaded_files).
-define(CONVERT, [integer, float, trim, digit_only, lower_case, upper_case]).

check(R, P) -> check(R, P, []).
check([], P, Msg) -> {P, Msg};
check([H|T], Post, Msg_ori) ->
    {K, Rs, Msg} = case H of
        {Key, Rules, Msgs} -> {Key, Rules, Msgs};
        {Key1, Rules1} -> {Key1, Rules1, <<"Error in validating">>}
    end,

    {Msg1, Post_res} = case K of 
        {FK, file} ->
            Files = proplists:get_value(?UD, Post, []),
            V = proplists:get_value(FK, Files),
            F_msg = case H of
                {_, _, _} -> [validator_file:validate(V, R, Msg) || R <- Rs];
                {_, _} -> [validator_file:validate(V, R) || R <- Rs]
            end,
            {F_msg, Post};
        _  -> 
            V = proplists:get_value(K, Post),
            {V_op, Rs1} = optimize(V, Rs),
            Post_del = proplists:delete(K, Post),
            Post_opt = [{K, V_op} | Post_del],
            V_op1 = case V_op of
                undefined -> <<"">>;
                _ -> V_op
            end,
            {[validate_key(K, V_op1, R, Msg) || R <- Rs1], Post_opt}
    end,
    check(T, Post_res, [Msg_ori | Msg1]).

optimize(V, Rs) -> 
    Rules = [R || R <- Rs, lists:member(R, ?CONVERT) == false],
    CR = [R || R <- Rs, lists:member(R, ?CONVERT) == true],
    V1 = optimize_field(V, CR),
    {V1, Rules}.

optimize_field(V, []) -> V;
optimize_field(V, [K | N]) -> 
    Vo = case K of
        int -> type:to_integer(V);
        integer -> type:to_integer(V);
        foat -> type:to_float(V);
        digit_only -> digit_only(V);
        lower_case -> string:lowercase(type:to_binary(V));
        upper_case -> string:uppercase(type:to_binary(V))
    end,
    optimize_field(Vo, N).


get_data([], _) -> [];
get_data([{K, V, _} | T], Post) ->get_data([{K, V} | T], Post);
get_data([{{F, file}, _} | T], Post) ->
    Fs = proplists:get_value(?UD, Post),
    [proplists:get_value(F, Fs) | get_data(T, Post)];
get_data([ _ = {K, _} | T ], Post) ->
    [proplists:get_value(K, Post) | get_data(T, Post)].

validate(R, P) -> validate(R, P,with_key).
validate(R, P, T) -> 
    {Post, Errors} = check(R, P),
    case lists:flatten(Errors) of
        [] -> get_data(R, Post);
        Msgs -> 
            Msg1 = lists:flatten(Msgs),
            Msg2 = case T of
                no_key -> [Msg || {_, Msg} <- Msg1];
                msg_only -> [Msg || {_, Msg} <- Msg1];
                _ -> Msg1
            end,
            {error, Msg2}
    end.

validate_key(K, V, {listsize_max, L}, Msg) -> case erlang:length(V) > L of true -> {K, Msg}; _ -> [] end;
validate_key(K, V, {listsize_min, L}, Msg) -> case erlang:length(V) < L of true -> {K, Msg}; _-> [] end;
validate_key(K, V, {listsize_range, {L, H}}, Msg) -> L1 = string:length(V), case L1 < L orelse L1 > H andalso L1 > 0 of true -> {K, Msg}; _ -> [] end;
validate_key(K, V, required, Msg) -> case string:length(V) < 1 of true -> {K, Msg}; _ -> [] end;
validate_key(K, V, {minlength, L}, Msg) -> case string:length(V) < L andalso string:length(V) > 0 of true -> {K, Msg}; _ -> [] end;
validate_key(K, V, {maxlength, L}, Msg) -> case string:length(V) > L of true -> {K, Msg}; _ -> [] end;
validate_key(K, V, {rangelength, {Min, Max}}, Msg) -> L1 = string:length(V), case L1 < Min orelse L1 > Max of true -> {K, Msg}; _ -> [] end;
validate_key(K, V, {length, {Min, Max}}, Msg) -> L1 = string:length(V), case L1 < Min orelse L1 > Max of true -> {K, Msg}; _ -> [] end;
validate_key(K, V, {min, V1}, Msg) -> case V < V1 of true -> {K, Msg}; _ -> [] end;
validate_key(K, V, {max, V1}, Msg) -> case V > V1 of true -> {K, Msg}; _ -> [] end;
validate_key(K, V, {range, {Min, Max}}, Msg) -> case V < Min orelse V > Max of true -> {K, Msg}; _ -> [] end;
validate_key(K, V, email, Msg) -> valid_email(K, V, Msg);
validate_key(K, V, phone, Msg) -> valid_phone(K, V, Msg);
validate_key(K, V, {equal_to, V1}, Msg) -> case V of V1 -> []; _ -> {K, Msg} end;
validate_key(K, V, {not_equal_to, V1},Msg) -> case V of V1 -> {K, Msg}; _ -> [] end;
validate_key(K, V, password, Msg) -> valid_password(K, V, Msg);
validate_key(K, V, {reg, R}, Msg) -> valid_reg(K, V, R, Msg).

validate_key(K, V, R) -> validator_msg:generate(K, V, R).

valid_email(K, undefined, Msg) -> {K, Msg};
valid_email(K, V, Msg) ->
    R = <<"^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$">>,
    case re:run(V,R, [global, {capture, first, binary}]) of
        nomatch -> {K, Msg};
        _ -> []
    end.

valid_phone(_, undefined, _) -> [];
valid_phone(_, <<"">>, _) -> [];
valid_phone(K, V1, Msg) ->
    V = digit_only(V1),
    io:format('V: ~p~n',[V]),
    R = <<"^\\d{8,12}$">>, 
    case re:run(V, R, [global, {capture, first, binary}]) of
        nomatch -> {K, Msg};
        _ -> []
    end.

valid_password(K, undefined, Msg) ->{K, Msg};
valid_password(K, Pwd, Msg)->
    Pattern = <<"((?=.*\\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[@!#\$&]).{8,20})">>,
    V = case re:run(Pwd, Pattern, []) of
        nomatch -> false;
        {match, _} -> true
    end,

    case V of true -> []; _ -> {K, Msg} end.

valid_reg(K, V, R, Msg) ->
    case re:run(V, R, [global, {capture, all, binary}]) of
        nomatch -> {K, Msg};
        _ -> []
    end.


digit_only(undefined) -> <<"">>;
digit_only(V) -> re:replace(V, <<"\\D">>, <<"">>, [global, {return, binary}]).
