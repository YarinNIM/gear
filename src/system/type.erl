-module(type).
-export([
    to_atom/1, 
    to_binary/1, to_bin/1,
    to_int/1, to_integer/1, 
    to_float/1, to_float/2, to_list/1,
    to_bool/1, to_boolean/1,
    to_phone/1, to_phone/2, digit_only/1, 
    jsx_decode/1, jsx_encode/1,

    to_date/1, to_date_time/1,  to_date_time/2,
    date_to_string/1, to_time/1, time_to_string/1,

    ceil/1, zero_to_null/1,

    list_to_map/1

]).
%-export([length/1, surround/1, surround/2]).
-export([cast/1, cast/2]).

to_atom(V) -> 
    erlang:binary_to_atom(to_binary(V), latin1).

to_boolean(V) -> to_bool(V).
to_bool(V1) ->
    V = string:trim(type:to_binary(V1)),
    case type:to_binary(V) of
        <<"false">> -> false;
        <<"0">> -> false;
        <<"null">> -> false;
        <<"undefined">> -> false;
        <<>> -> false;
        <<"off">> -> false;
        _ -> true
    end.

to_bin(V) -> to_binary(V).
to_binary(V) when is_integer(V) -> erlang:integer_to_binary(V);
to_binary(V) when is_atom(V) -> erlang:atom_to_binary(V, latin1);
to_binary(V) when is_list(V) -> erlang:list_to_binary(V);
to_binary(V) when is_float(V) -> erlang:float_to_binary(V, [{decimals, 4}]);
to_binary(V) when is_binary(V) -> V.

to_int(V) -> to_integer(V).
to_integer(undefined) -> 0;
to_integer(V) when is_integer(V) -> V;
to_integer(V) -> 
    V1 = type:to_binary(V),
    Vb = iolist_to_binary(re:replace(V1, <<"\\..+$">>, <<"">>, [global])),
    try erlang:binary_to_integer(Vb)
    catch _:_ -> 0
    end.
%to_integer(V) when is_float(V) -> to_integer(to_binary(V)).


to_float(V) when is_float(V) -> V;
%to_float(V) when is_list(V) -> erlang:list_to_float(V):
%to_float(V) when is_binary(V) -> erlang:binary_to_float(V);
to_float(V) ->
    Vb = to_binary(string:trim(V)),
    V1 = case re:run(Vb, <<"\\.">>) of
             nomatch -> <<Vb/binary, ".00">>;
             _ -> Vb
         end,
    try erlang:binary_to_float(V1) 
    catch _:_ -> 0.00 end.

to_float(V, D) ->
    V1 = to_float(V),
    V2 = erlang:float_to_binary(V1, [{decimals, D}]),
    to_float(V2).


%to_list(I) when is_binary(I) -> to_list(erlang:binary_to_list(I));
%to_list(I) when is_integer(I) -> to_list(erlang:integer_to_list(I));

to_list(I) when is_list(I) -> I;
to_list(I) -> erlang:binary_to_list(type:to_binary(I)).

jsx_encode(X) -> 
    case catch jsx:encode(X) of
        {'EXIT', _} -> <<"{}">>;
        Res -> Res
    end.
jsx_decode(X) -> 
    case catch jsx:decode(X) of
        {'EXIT', _} -> [];
        Res -> Res
    end.

digit_only(V) ->
    S = to_binary(V),
    case re:run(S, <<"\\d+">>, [global,{capture, all, binary}]) of
        {match, M} -> to_binary(M);
        nomatch -> <<"">>
    end.

to_phone(P) -> to_phone(<<"855">>, P).
to_phone(Prefix, P) ->
    P1 = digit_only(P),
    Re = <<"^(", Prefix/binary, ")?0*(\\d+)$">>,
    Phone =case re:run(P1, Re, [global, {capture, all, binary}]) of
               nomatch -> P1;
               {match, [[_,  _, P2]]} -> <<"0", P2/binary>>
           end, 
    Res = case re:run(Phone, <<"^\\d{9,10}$">>, [global, {capture, all, binary}]) of
              nomatch -> nomatch;
              {match, [[Phone1]]} -> {Prefix, Phone1}
          end,
    Res.

ceil(N) when N < 0 -> erlang:trunc(N);
ceil(N) ->
    T = erlang:trunc(N),
    case N - T == 0 of
        true -> T;
        _ -> T +1
    end.

cast(L) -> [cast(V, T) || {V, T} <- L].
cast(V, T) ->
    case T of
        atom -> to_atom(V);
        bin -> to_binary(V);
        binary -> to_binary(V);
        int -> to_integer(V);
        bool -> to_bool(V);
        float -> to_float(V);
        digit_only -> digit_only(V);
        jsx_encode -> jsx_encode(V);
        jsx_decode -> jsx_decode(V);
        list -> to_list(V)
    end.

to_date({Y, M, D}) -> {Y, M, D};
to_date(V) ->
    case string:split(V,"-", all) of
        [0, _, _] -> error;
        [Y, M, D] -> 
            Y1 = to_integer(Y),
            M1 = to_integer(M),
            D1 = to_integer(D),
            to_date_check(Y1, M1, D1);
        _ -> error
    end.

to_date_time(V) -> to_date_time(V, erlang:time()).
to_date_time(D, T) ->
    case to_date(D) of
        error -> error;
        Date -> {Date, to_time(T)}
    end.

to_date_check(0, _, _) -> error;
to_date_check(Y, M, D) ->
    case calendar:valid_date(Y, M, D) of
        true -> {Y, M, D};
        _ -> error
    end.

to_time(V) -> to_time(V, erlang:time()).
to_time({H, M}, _Fb) -> {H, M, 0};
to_time({H, M, S}, _Fb) -> {H, M, S};
to_time(V, Fb) ->
    case string:split(V, ":", all) of
        [H, M] -> { type:to_int(H), type:to_int(M) , 0};
        [H1, M1, S1] -> { type:to_int(H1), type:to_int(M1), type:to_int(S1)};
        _ -> Fb
    end.

date_to_string(D) when is_binary(D) -> D;
date_to_string({Y, M, D}) -> to_binary(to_list(Y) ++ "-" ++ to_list(M) ++ "-" ++ to_list(D)).

time_to_string(T) when is_binary(T) -> T;
time_to_string(T) when is_list(T) -> T;
time_to_string({H, M}) -> time_to_string({H, M, 0});
time_to_string({H, M, S}) -> 
    T = type:to_list(H) ++ ":"++ type:to_list(M) ++ ":" ++ type:to_list(S),
    type:to_binary(T).

zero_to_null(<<>>) -> null;
zero_to_null(0) -> null;
zero_to_null(false) -> null;
zero_to_null([]) -> null;
zero_to_null(Else) -> Else.


list_to_map(L) -> list_to_map(L, #{}).
list_to_map([], M) -> M;
list_to_map([{K, V}|T], M) ->
    list_to_map(T, M#{to_atom(K) => V}).
