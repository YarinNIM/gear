-include("../env.hrl").
-module(env).
-export([
    get/0,
    get/1, get/2
]).


get() -> ?ENV.

%% @doc Return the maps value
%% from specific key
get(Key) -> get(Key, undefined).
get(Key, Def) ->
    case maps:find(Key, ?ENV) of
        error -> Def;
        {ok, V} -> V
    end.


