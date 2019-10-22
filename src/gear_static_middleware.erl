-module(gear_static_middleware).
-behavior(cowboy_middleware).
-export([ execute/2]).

execute(Req, Env) -> 
    {ok, Req, Env}.
