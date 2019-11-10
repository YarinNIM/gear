%% @author Yarin NIM <yarin.nim@gmail.com>
%% @copyright 2019 Yarin NIM
%% @version 0.1
%% @title Home Controller
%% @doc Description about documentation


-module(cam_home_controller).
-export([
    index_action/3,
    test_action/3
]).

index_action(Req, State, _) ->
    Res = resource:render_page( #{
        js => [ 
            config:base_url(<<"js/home.js">>, State),
            config:locale_url(<<"services">>, State)
        ],
        on_script_loaded => [<<"_.initHome(); ">>]
    }, Req, State),

    {Res, Req, State}.


test_action(Req, State, _) ->
    io:format('Hers ithe content'),
    {<<"Good">>, Req, State}.


