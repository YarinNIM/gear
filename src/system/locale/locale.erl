-module(locale).
-include("../../language/kh.hrl").
-include("../../language/en.hrl").
-export([get/1, get/2, to_unicode/1]).

get(Lang)->
    Locale = case Lang of 
        <<"en">> -> ?EN;
        <<"kh">> -> to_unicode(?KH)
    end,
    Locale.

get(K, State) when is_binary(K) ->
    get(binary_to_atom(K, latin1), State);
get(K, State) when is_list(K) ->
    get(list_to_atom(K), State);
get(K, State) when is_atom(K) ->
    Locale = proplists:get_value(locale, State),
    proplists:get_value(K, Locale).

to_unicode(Lang) -> 
    [{ K, convert(V) } || {K, V} <- Lang].
%
convert(U) -> 
    U2 = unicode:characters_to_binary(U, utf8),
    <<""/binary, U2/binary, ""/binary>>.
