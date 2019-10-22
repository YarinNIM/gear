-module(db_query_builder_action).
-include("type.hrl").
-export([
    compile_data/2, insert/3,

    test/0

]).


%insert(T, Data, Col_info) ->
%   Table = type:to_binary(T),
%   Params = data_params(Data, Col_info),
%   Fields = data_fields(Data),
%   Bind = data_bind(Data),
%   Query = <<"insert into ", Table/binary, 
%   "(", Fields/binary,") values(", Bind/binary,")">>,
%   {Query, Params}.

%% @doc return the type of an array field
array_type(T) -> 
    case lists:member(T, [<<"_bpchar">>, <<"_varchar">>, <<"_text">>])  of
        true -> string;
        _ -> false
    end.


%% @doc converts list of string from erlang
%% to array string which understand by PostgreSQL
array_string(Vals) ->
    Res = lists:foldl(fun(Item, In) ->
        I = type:to_binary(Item),
        if 
            erlang:bit_size(In) > 0 -> <<In/binary, ", \"", I/binary, "\"">>;
            true -> <<"\"", I/binary, "\"">>
        end
    end, <<"">>, Vals),
    <<"{", Res/binary, "}">>.


%% @doc Returns the compiled value to 
%% data which understand by PostgreSQL
data_value(V, {<<"ARRAY">>, T}) ->
    case array_type(T) of
        string -> array_string(V);
        _ -> V
    end;
data_value(V, {<<"jsonb">>, _}) -> jsx:encode(V);
data_value(V, _) -> V.

%% @doc Return the data with compile value
compile_data(Data, Col_info) ->
    maps:map(fun(K, V) ->
        Field = type:to_binary(K),
        #{ Field := Info} = Col_info,
        data_value(V, Info)
    end, Data).

insert_params(C) -> insert_params(C, 1).
insert_params(Compiled_data, Indx) ->
    maps:fold(fun(K, V, {Fields_bin, Param, Bind, Index})->
        Field = type:to_binary(K),
        Sep = case Bind of
            [] -> <<"">>;
            _ -> <<", ">>
        end,

        I = type:to_binary(Index),

        {
            <<Fields_bin/binary, Sep/binary, Field/binary>>,
            <<Param/binary, Sep/binary, "$", I/binary>>,
            Bind ++ [V],
            Index + 1
        }
    end, {<<"">>, <<"">>, [], Indx}, Compiled_data).

insert(Table, Data, Col_info) ->
    Compiled_data = compile_data(Data, Col_info),
    {Fields_bin, Param_bin, Bind, _Index} = insert_params(Compiled_data),
    Tbl = type:to_binary(Table),
    Sql = <<"insert into ", Tbl/binary,"(", Fields_bin/binary,") values(", Param_bin/binary, ")">>,
    {Sql, Bind}.


test() ->
    Data = #{
        id=>12,
        array_char => [<<"fdaf">>, <<"fdafda">>],
        char => <<"fdafda">>
    },

    Col_info = db:column_info(test_a),
    insert(test_a, Data, Col_info).

