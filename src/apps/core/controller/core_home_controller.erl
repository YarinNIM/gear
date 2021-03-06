%% @author Yarin NIM <yarin.nim@gmail.com>
%% @copyright 2019 Yarin NIM
%% @version 0.1
%% @title Home Controller
%% @doc Description about documentation

-module(core_home_controller).
-export([
    index_action/3, post_action/3,
    test_get_action/3,
    test_bind_action/3
]).

index_action(Req, State, _) ->
    {<<"welcome">>, Req, State}.

post_action(Req, State, _) ->
    {<<"Post">>, Req, State}.


test_get_action(Req, State, _) ->
    Params = cowboy_req:bindings(Req),
    io:format('Param a: ~p~n',[Params]),
    {<<"fdsaf">>, Req, State}.

test_bind_action(Req, State, _) ->
    Bind = cowboy_req:bindings(Req),
    io:format('Bing: ~p~n',[Bind]),
    {<<"good">>, Req, State}.
