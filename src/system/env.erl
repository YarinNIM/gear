-include("../env.hrl").
-module(env).
-export([
    get/1, get/2
]).


%% @doc Return the maps value
%% from specific key
get(Key) -> get(Key, undefined).
get(Key, Def) ->
    case maps:find(Key, ?ENV) of
        error -> Def;
        {ok, V} -> V
    end.


