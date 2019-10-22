-module(db_query).
-export([
    map_val/2, map_val/3,
    select/1, from/1, inner_join/1, left_join/1,
    where/1, order_by/1, limit/1, offset/1
]).

map_val(K, M) -> map_val(K, M, undefined).
map_val(K, M, D) ->
    case maps:find(K, M) of
        error -> D;
        {ok, V} -> V
    end.
get_item(K, M, A) ->
    case map_val(K, M, false) of
        false -> "";
        V -> type:to_list(A) ++ type:to_list(V)
    end.

select(M) -> "select " ++  map_val(select, M, "*").
from(M) -> "from " ++ map_val(from, M, "table").
inner_join(M) -> 
    case map_val(inner_join, M, false) of
        false -> "";
        {T, FA, FB} -> 
            " inner join " ++
            type:to_list(T) ++ " on " ++ 
            type:to_list(FA) ++ " = " ++ type:to_list(FB)
    end.

left_join(M) ->
    case map_val(left_join, M, false) of
        false -> "";
        {T, Fa, Fb} -> 
            " left outer join " ++
           type:to_list(T) ++ " on " 
           ++ type:to_list(Fa) ++ " = " ++ type:to_list(Fb)
    end.

order_by(M) -> get_item(order_by, M, " order by ").
limit(M) -> get_item(limit, M, " limit ").
offset(M) -> get_item(offset, M, " offset ").
where(M) ->
    Where = map_val(where, M, #{}),
    case db_query_builder:where(Where) of
        {<<>>, _, _} -> {"", []};
        {Sql, Bind, _} -> 
            {" where "++ type:to_list(Sql), Bind}
    end.
