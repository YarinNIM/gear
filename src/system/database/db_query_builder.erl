-module(db_query_builder).
-include("type.hrl").
-export([
    to_date/1,
    map_val/2, map_val/3, 
    array_number/1,
    select/1, from/1, 
    where/1, where/2,
    order_by/1, limit/1,
    query/1, insert/3,
    params_to_binded/1
]).

%% @doc Return map value if exists, 
%% owtherwise return default value defined in the function.
-spec map_val(term(), map()) -> term().
map_val(K, M) -> map_val(K, M, <<"">>).
map_val(K, M, D) -> 
    case maps:find(K, M) of
        error -> D;
        {ok, V} -> V
    end.

%% @doc Returns the list of selected fields into joined string
%% separated by comma (,)
-spec select([binary() | atom() | list()]) -> binary().
select(S) -> 
    %${select := S }= Query,
    S1 = lists:join(<<", ">>, [type:to_binary(Item) || Item <- S]),
    Select = erlang:iolist_to_binary(S1),
    <<"select ", Select/binary>>.

%% @doc Return the binary of
%% FROM query including JOIN Clause
%-spec from( Table::string() | { Table::string(), [ Join_tables:: join_table_type() ]}) -> binary().
-spec from(Form::from_type()) ->binary().
from(Fr) -> 
    From = case Fr of
        {Tbl,Alias} -> type:to_binary(type:to_list(Tbl) ++ " "++ type:to_list(Alias));
        Tbl_1 -> type:to_binary(Tbl_1)
    end,
     <<"from ", From/binary>>.

join_tables(Joins) -> 
    Res = maps:fold(fun(Tbl, J, I) ->
        I ++  join_table(Tbl, J)
    end, "",  Joins),
    case Res of 
        "" -> <<"">>;
        Res -> type:to_binary(" "++ Res ++ " ")
    end.

-spec join_table(Table::term(), {FieldA::term(), FieldB::term(), Join_type::atom()}) -> binary().
join_table(T, {A, B}) -> join_table(T, {A, B, inner});
join_table(Tbl, {A, B, T}) ->
    Tbl1 = type:to_list(Tbl),
    A1 = type:to_list(A),
    B1 = type:to_list(B),
    T1 = case T of
        inner -> "inner";
        left_outer -> "left outer";
        right_outer -> "right outer"
    end,

    T1 ++ " join " ++ Tbl1 ++ " on " ++
    A1 ++ " = " ++ B1 ++ " ".




%% @doc Returns list of where with caluse
-spec where_add_preposition([map()]) -> [{preposition_type(), map()}].
where_add_preposition(M) -> where_add_preposition(M,1).
where_add_preposition(M, S) when is_map(M) ->
    case maps:size(M) of
        0 -> where_add_preposition([]);
        _ -> where_add_preposition([M], S)
    end;
where_add_preposition(Wheres, Start_index) ->
    lists:foldr(fun(Item, {Where_in, I}) ->
        {Clause, Where} = case Item of
            {Cl, Where_map} -> {type:to_binary(Cl), Where_map};
             Where_map -> {<<"and">>, Where_map}
        end,
        {Where_bin, Where_binded, Where_index} = where_binary(Where, I),
        Where_1 = {Clause, Where_bin, Where_binded},
        Wheres_res = case Clause of
            {<<"and">>, _} -> [Where_1] ++ Where_in;
            _ -> Where_in ++ [Where_1]
        end,
        {Wheres_res, Where_index}
    end, {[], Start_index},  Wheres).

%% @doc Add each key of where to fully understandable 
%% {value, operant, caluse}
where_binary(Where, Init) ->
    Keys = maps:fold(fun(K, Val, I) ->
        V1 = case Val of
            %not_null -> {not_null, not_null, <<"and">>};
            %{not_null, C} -> {not_null, not_null, type:to_binary(C)};
            %null -> {null, null, <<"and">>};
            %{null, C} -> {null,null, typ:to_binary(C)};
            {V, Op} ->  {V, type:to_binary(Op), <<"and">>};
            {V, Op, C} -> {V, type:to_binary(Op), type:to_binary(C)};
            V -> {V, <<"=">>, <<"and">>}
        end,

        case V1 of
            {_, _, <<"or">>} -> I ++ [{type:to_binary(K), V1}];
            _ -> [{type:to_binary(K), V1}] ++ I
        end
    end, [], Where),
    where_keys_bind(Keys, Init).

where_keys_bind(Where, Index) ->
    {Where_bin, Binded, E_index} = lists:foldl(fun({F, Val}, Res) ->
        where_key_bind(F, Val, Res)
    end, {<<"">>, [], Index}, Where),
    Where_bin1= string:trim(Where_bin),
    case Where_bin1 of
        <<"">> -> {<<"">>, Binded, E_index};
        _ -> {<<"(", Where_bin1/binary, ")">>, Binded, E_index}
    end.

where_key_bind_prep(Prep, Res) ->
    case Res of 
        <<"">> -> <<"">>;
        _ -> <<" ", Prep/binary>>
    end.

where_key_bind(Field, {null, _, Prep}, Res) -> where_key_bind(Field, {<<"is null">>, null, Prep}, Res);
where_key_bind(Field, {is_null, _, Prep}, Res) -> where_key_bind(Field, {<<"is null">>, null, Prep}, Res);
where_key_bind(Field, {not_null, _, Prep}, Res) -> where_key_bind(Field, {<<"is not null">>, null, Prep}, Res);
where_key_bind(Field, {is_not_null, _, Prep}, Res) -> where_key_bind(Field, {<<"is not null">>, null, Prep}, Res);
where_key_bind(Field, {V, null, Pre}, {Binary, Binds, Index}) ->
    Prep = where_key_bind_prep(Pre, Binary),
    {
        <<Binary/binary, " ", Prep/binary, " ", Field/binary, " ", V/binary>>,
        Binds, Index
    };
where_key_bind(_, {<<"">>, _, _}, {Bin, Binds, Index}) -> {Bin, Binds, Index};
where_key_bind(_, {"", _, _}, {Bin,Binds, Index}) -> {Bin, Binds, Index};
where_key_bind(_, {<<"%">>, _, _}, {Bin,Binds, Index}) -> {Bin, Binds, Index};
where_key_bind(_, {<<"%%">>, _, _}, {Bin,Binds, Index}) -> {Bin, Binds, Index};
where_key_bind(F, {V, O, Pre}, {Bin, Binds, Index}) ->
    Prep = where_key_bind_prep(Pre, Bin),
    I_bin = type:to_binary(Index),

    {
        <<Bin/binary, " ", Prep/binary, " ", F/binary," ", O/binary, " $", I_bin/binary>>,
        Binds ++ [V],
        Index +1
    }.

where([]) -> {<<"">>, [], 1};
where(W) -> where(W, 1).
where(Wh, Start_index) -> 
    {Wheres, Index} = where_add_preposition(Wh, Start_index),
    {Bin_r, Bind_r} = lists:foldl(fun({Cls, Where_bin, Where_binded}, {Bin, Bind}) ->
                                        
        case string:trim(Where_bin) of
            <<>> -> {Bin, Bind};
            _ -> 
                Clause = case Bind of
                [] -> <<"">>;
                    _ -> <<" ", Cls/binary>>
                end,

                {
                    <<Bin/binary, Clause/binary, " ", Where_bin/binary>>, 
                    Bind ++ Where_binded
                }
        end
    end, {<<"">>, []}, Wheres),
    {string:trim(Bin_r), Bind_r, Index}.

%% @doc Returns order by string
-spec order_by(#{
    Field::string() => Order_dir:: order_by_type()
}) -> binary().
order_by(M) ->
    Order = maps:fold(fun(K, V, I) ->
        K1 = type:to_binary(K),
        V1 = type:to_binary(V),
        I ++ [<<K1/binary, " ", V1/binary>>]
    end, [], M),

    case Order of 
        [] -> <<"">>;
        _ -> 
            Order_1 = iolist_to_binary(lists:join(<<", ">>, Order)),
            <<" order by ", Order_1/binary>>
    end.

limit(0) -> <<"">>;
limit(undefined) -> <<"">>;
limit(Lm) -> 
    Lm1 = type:to_binary(Lm),
    <<" limit ",Lm1/binary>>.

offset(undefined) -> <<"">>;
offset(Offset) ->
    Os1 = type:to_binary(Offset),
    <<" offset ", Os1/binary>>.

query(Query) ->
    {Where, Binded_params, _}  = case where(map_val(where, Query, [])) of
        {<<"">>, _, _} -> {<<"">>, [], 0};
        {Where_bin, Where_bind, I} -> {<<"where ", Where_bin/binary>>, Where_bind, I}
    end,

    #{select := Sel} = Query,
    Select = select(Sel),

    #{from := Frm } = Query,
    From = from(Frm),

    Join = join_tables(map_val(join, Query, #{})),

    Order_by = order_by(map_val(order_by, Query, #{})), 
    Limit = limit(map_val(limit, Query, 0)),
    Offset = offset(map_val(offset, Query, undefined)),

    {
        <<Select/binary, " ", From/binary, " ",
        Join/binary,
        Where/binary,
        Order_by/binary, 
        Limit/binary, Offset/binary>>,
        Binded_params
    }.

%% @doc Insert data into table
-spec insert(Table::string(), Data::map(), Column_info::#{
    Column::binary() => {Data_type::data_type(), UDT_type::udt_type()}
 })-> term().
insert(Table, Data, Col_info) -> db_query_builder_action:insert(Table, Data, Col_info).


%% @doc conver list of number into array list
%% understands by PostgreSQL
%% [1,3,4,] => '{1,2,3}'
array_number(L) ->
    L_bin = [type:to_binary(I) || I <- L],
    L1 = lists:join(",", L_bin),
    L1_bin = erlang:iolist_to_binary(L1),
    <<"{", L1_bin/binary,"}">>.


%% @doc Return the parameter list to 
%% binded number
%% eg; [a, b,c ] will return $1, $2, $3
-spec params_to_binded(Params::list()) -> binary().
params_to_binded(Params) ->
    {_, Binded} = lists:foldl(fun(_, {I, L}) ->
        {I+1, L ++ [type:to_binary("$" ++ type:to_list(I))]}
    end, {1, []}, Params),

    erlang:list_to_binary(lists:join(<<",">>, Binded)).


%% @doc return Erlang date to PostgreSQL date
to_date({Date, _}) -> to_date(Date);
to_date({Y, M, D}) ->
    Date = type:to_list(Y) ++ "-" ++
    type:to_list(M) ++ "-" ++
    type:to_list(D),
    type:to_binary(Date).


