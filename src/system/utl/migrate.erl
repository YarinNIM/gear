-module(migrate).
-export([migrate_account/0, drop_table/1, create_table/2]).
-export([run_sql/0]).

migrate_account() ->
    Sql = "truncate table account",
    Sql.

run_sql() ->
    Res = os:cmd("./db/migrate/account.sh"),
    io:format('Res: ~p~n',[Res]).


drop_table(N) when not is_list(N) -> drop_table(type:to_list(N));
drop_table(N) ->
    Sql = "drop table " ++ N ++ " cascade;",
    db:execute(Sql).


create_table(Name, F) ->
    N =type:to_list(Name),
    Fields = fields(F),
    Sql = "create table "++ N ++"("++Fields++" id serial)",
    db:execute(Sql).

fields(F) -> fields(F, "").
fields([], Str) -> Str;
fields([{_K, V}|T], Str) -> 
    fields(T, 
       Str ++ type:to_list(V) ++ " varchar, "
    ).



