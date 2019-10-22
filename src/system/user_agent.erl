-module(user_agent).
-include("include/user_agents.hrl").
-export([
    info/1, user_agent/1, 
    browsers/0, platforms/0, mobiles/0, robots/0,
    is_mobile/1

]).
-define(V(K,L), proplists:get_value(K, L)).

browsers() -> ?BROWSERS.
platforms() -> ?PLATFORMS.
mobiles() -> ?MOBILES.
robots() -> ?ROBOTS.


headers(Req) -> cowboy_req:headers(Req).
user_agent(Req) -> 
    #{<<"user-agent">> := UA} = headers(Req),
    UA.

info(Req) ->
    UA = user_agent(Req),
    #{
       ip => get_ip(Req),
       user_agent => UA,
       browser =>  ok
    }.

get_ip(Req) -> 
    {Ip, _} = cowboy_req:peer(Req),
    case Ip of
        {_, _, _, _} -> 
            L = erlang:tuple_to_list(Ip),
            L1 = [type:to_binary(I) || I <- L],
            L2 = lists:join(<<".">>, L1),
            erlang:iolist_to_binary(L2);
        _ -> type:to_binary(Ip)
    end.


is_mobile(Req) -> 
    UA = user_agent(Req),
    maps:fold(fun(K, _V, I) ->
        case re:run(UA, K) of
            nomatch -> I;
            _ -> true
        end
    end, false, ?MOBILES).


