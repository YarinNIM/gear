-module(validator).
-export([
    validate/2,
    validate_throttle/2
]).

-spec validate_throttle(Key::binary(), Value::number()) -> boolean().
validate_throttle(K, V) ->  
    T = config:throttle(K),
    case T > V of
        true -> ok;
        _ -> {error, T}
    end.

-spec validate(Rules::map(), Post::list()) -> {error, map()} | list().
validate(Rules, Post) ->
    {Res_error, Res_val} = maps:fold(fun(K, {Rs,Msg}, {Errs, Vals}) ->
        Field_val = proplists:get_value(type:to_binary(K), Post),
        Field_val1 = optimize(Field_val, Rs),
        Err_1 = case validate_keys(Field_val1, Rs) of
            0 ->  Errs;
            _ -> Errs#{K => Msg}
        end,
        {Err_1, Vals#{K => Field_val1}}
    end, {#{}, #{}}, Rules),

    case maps:size(Res_error) of
        0 -> Res_val;
        _ -> {error, Res_error}
    end.


optimize(undefined, R) -> optimize(<<>>, R);
optimize(V, []) ->V;
optimize(V, [H|T]) ->
    V1 = case H of
        int -> type:to_integer(V);
        integer -> type:to_integer(V);
        float -> type:to_float(V);
        digit_only -> type:digit_only(V);
        lower_case -> string:lowercase(type:to_binary(V));
        upper_case -> string:uppercase(type:to_binary(V));
        date -> type:to_date(V);
        date_time -> type:to_date_time(V);
        bool -> type:to_boolean(V);
        boolean -> type:to_boolean(V);
        _ -> V
    end,
    optimize(V1, T).

validate_keys(V, Rules) -> 
    Res = lists:foldr(fun(Rule, I) ->
        I+ validate_key(V, Rule)
    end, 0, Rules),
    Res.

validate_key(error, required) -> 1;
validate_key({Y, M, D}, required) -> case calendar:valid_date(Y, M, D) of false -> 1; _ -> 0 end;
validate_key(V, required) -> case string:length(V) < 1 of true -> 1; _ -> 0 end;

validate_key(V, {listsize_max, L}) -> case erlang:length(V) > L of true -> 1; _ -> 0 end;
validate_key(V, {listsize_min, L}) -> case erlang:length(V) < L of true -> 1; _-> 0 end;
validate_key(V, {listsize_range, {L, H}}) -> L1 = string:length(V), case L1 < L orelse L1 > H andalso L1 > 0 of true -> 1; _ -> 0 end;

validate_key(V, {minlength, L}) -> case string:length(V) < L andalso string:length(V) > 0 of true -> 1; _ -> 0 end;
validate_key(V, {maxlength, L}) -> case string:length(V) > L of true -> 1; _ -> 0 end;
validate_key(V, {rangelength, {Min, Max}}) -> L1 = string:length(V), case L1 < Min orelse L1 > Max of true -> 1; _ -> 0 end;
validate_key(V, {length, {Min, Max}}) -> L1 = string:length(V), case L1 < Min orelse L1 > Max of true -> 1; _ -> 0 end;
validate_key(V, {min, V1}) -> case V < V1 of true -> 1; _ -> 0 end;
validate_key(V, {max, V1}) -> case V > V1 of true -> 1; _ -> 0 end;
validate_key(V, {range, {Min, Max}}) -> case V < Min orelse V > Max of true -> 1; _ -> 0 end;
validate_key(V, email) -> valid_email(V);
validate_key(V, phone) -> valid_phone(V);
validate_key(V, {equal_to, V1}) -> case V of V1 -> 0; _ -> 1 end;
validate_key(V, {not_equal_to, V1}) -> case V of V1 -> 1; _ -> 0 end;
validate_key(V, password) -> valid_password(V);
validate_key(error, date) -> 1;
validate_key(error, date_time) -> 1;
validate_key(V, {reg, R}) -> valid_reg(V, R);
validate_key(_, _) -> 0.


valid_email(<<>>) -> 0;
valid_email(V) ->
    R = <<"^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$">>,
    case re:run(V,R, [global, {capture, first, binary}]) of
        nomatch -> 1;
        _ ->0 
    end.

valid_phone(<<"">>) -> 0;
valid_phone(V1) ->
    V = type:digit_only(V1),
    R = <<"^\\d{9,12}$">>, 
    case re:run(V, R, [global, {capture, first, binary}]) of
        nomatch -> 1;
        _ ->0 
    end.

valid_password(<<>>) -> 1;
valid_password(Pwd)->
    Pattern = <<"((?=.*\\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[@!#\$&]).{8,20})">>,
    case re:run(Pwd, Pattern, []) of
        nomatch -> 1;
        {match, _} -> 0
    end.

valid_reg(V, R) ->
    case re:run(V, R, [global, {capture, all, binary}]) of
        nomatch -> 1;
        _ ->0 
    end.

