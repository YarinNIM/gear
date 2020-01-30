%% @author Yarin NIM <yarin.nim@gmail.com>
%% @copyright 2019
%% @doc Database migration

-module(migration).
-export([
    migrate/0, migrate/1
]).

defaultProps(Props) -> 
    maps:merge(#{
        refresh => false,
        seeder => false
    }, Props).

migrate() -> migrate(#{}).
migrate(Props0) ->
    Props = defaultProps(Props0),
    Props.
