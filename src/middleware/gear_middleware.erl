%% @author Yarin NIM <yarin.nim@gmail.com>
%% @copyright 2019 Yarin NIM
%% @version 0.1
%% @title System Middleware
%% @doc This module is to behave as middleware of the system

-module(gear_middleware).
-behavior(cowboy_middleware).
-export([ execute/2]).

execute(Req, Env) -> 
    Req1 = cowboy_req:set_resp_headers(#{
        %% <<"access-control-allow-origin">> => <<"*">>,
        <<"system-version">> => <<"Initial Version">>,
        <<"server">> => <<"Gear System 0.1">> %% Get the server header to response
    }, Req),
    {ok, Req1, Env}.


