%% @author Yarin NIM <yarin.nim@gmail.com>
%% @copyright 2019 Yarin NIM
%% @version 0.1
%% @title Home Controller
%% @doc Description about documentation

-module(core_home_controller).
-export([
    index_action/3,
    test_action/3,
    test_bind_action/3
]).

index_action(Req, State, _) ->
    {<<"welcome">>, Req, State}.


test_action(Req, State, _) ->
    {<<"fdsaf">>, Req, State}.

test_bind_action(Req, State, _) ->
    Bind = cowboy_req:bindings(Req),
    io:format('Bing: ~p~n',[Bind]),
    {<<"good">>, Req, State}.
