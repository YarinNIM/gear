-module(get_list).
-export([get_value/2]).

get_value([], _) -> [];
get_value(Ks , L) when is_list(L) -> 
    [value_list(K,L) || K <- Ks];
get_value(Ks, L) when is_map(L) -> 
    get_map_values(Ks, L).

value_list({K,T},L)->
    V = proplists:get_value(K,L),
    to_type(V,T);
value_list(K,L) -> proplists:get_value(K,L).


get_map_values([], _) -> [];
get_map_values(Ks, L) -> get_map_values(Ks, L, []).
get_map_values([], _, L) -> L;
get_map_values([H|T], L, R) ->
    V = get_map_value(H, L),
    R1 = R ++ [V],
    get_map_values(T, L, R1).

get_map_value({K, T}, M) ->
    case maps:find(K, M) of
        error-> undefined;
        {ok, V} -> to_type(V, T)
    end;
get_map_value(K, M) ->
    case maps:find(K, M) of
        error -> undefined;
        {ok, V} -> V
    end.


to_type(V,T) ->
    case T of
        atom -> type:to_atom(V);
        int -> type:to_integer(V); %erlang:binary_to_integer(V);
        integer -> type:to_integer(V);
        float -> type:to_float(V); %erlang:binary_to_float(V);
        binary -> type:to_binary(V);
        bin -> type:to_binary(V);
        digit_only -> type:digit_only(V);
        list -> type:to_list(V);
        boolean -> type:to_bool(V);
        bool -> type:to_bool(V);
        jsx_decode -> type:jsx_decode(V);
        jsx_encode -> type:jsx_encode(V)
    end.


