-module('template').
-export([
    render/1, 
    render/2
]).
-define(KEY(K, P), proplists:get_value(K,P)).
-type page():: list() | atom() | binary().

-spec render(any()) -> binary().
-spec render(page(), map()) -> binary().
render(C) -> render(C, []).
render(L, Params) when is_list(L) ->
    render(type:to_binary(L), Params);
render(Content, Params) when is_binary(Content)->
    erlydtl:compile_template(Content, tmp_template_dtl),
    render(tmp_template, Params);
render(Page, Params) when is_atom(Page)->
    Thepage = atom_to_list(Page) ++ "_dtl",
    Modul = list_to_atom(Thepage),
    {ok, Rendered} = Modul:render(Params,[{auto_escape, true}]),
    list_to_binary(Rendered).
