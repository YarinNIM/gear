%% @author Yarin NIM <yarin.nim@gmail.com>
%% @copyright 2019 Yarin NIM
%% @version 0.1
%% @title Home Controller
%% @doc Description about documentation


-module(core_home_controller).
-export([
    index_action/3
]).

index_action(Req, State, _) ->
    io:format('Req: ~p~n',[Req]),
    Res = resource:render_page( #{
        js => [],
        on_script_loaded => []
    }, Req, State),

    {Res, Req, State}.
