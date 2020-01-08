-module(gear_static_middleware).
-behavior(cowboy_middleware).
-export([ execute/2]).

execute(Req, Env) -> 
    io:format('Env: ~p~n',[Env]),
    {ok, Req, Env}.
