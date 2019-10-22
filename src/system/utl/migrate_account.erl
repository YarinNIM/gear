% @author Yarin NIM
% @doc This is to migrage the account information.
% The account information is included with EMAIL table 
% and EMAIL table

-module(migrate_account).
-include("include/account.hrl").
-export([migrate/0]).

migrate() -> 
    io:format(' - Hash password').
