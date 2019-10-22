%% @doc Resource page is to render the page based on
%% application resource
%%
-module(resource_page).
-define(V(K,L), proplists:get_value(K, L)).
-define(V(K, L, D), proplists:get_value(K, L, D)).
-export([
    merge_items/1, merge_items/2,
    render/2,render/3
]).


resource(State) ->
    #{ app := App_opts} = State,
    App = ?V(app, App_opts),
    App:resource().

render(R, S) -> render([], R, S).
render(_App_param, _Req, State) ->
    Resource = resource(State),
    Params = [
        {csss, css(Resource)},
        {js, js(Resource)},
        %{js, js(Param, State)},
        %{global_js, ?KEY(global_js,Param, [])},
        %{on_script_loaded, ?KEY(on_script_loaded,Param, [])},
        %{variables, ?RES(variables,  Param)},
        {state, State}
        %{query_string, ?KEY(query_string, Param)}
    ],
    template:render(resource_page, Params).



merge_items(Res) -> merge_items(Res, production).
merge_items(Res, K) ->
    Pro = ?V(K, Res),
    Items = proplists:delete(K, Res),
    Items ++ Pro.

css(Res) -> merge_items(?V(css, Res)).

js(Res) ->
    JSs = ?V(js, Res),
    Pre = [js_params(Item) || Item <- merge_items(?V(preload, JSs))],
    Init = [js_params(Item) || Item <- merge_items(?V(init, JSs))],
    [{ preload, Pre},{init, Init}].

js_params({K, U})-> {K, U, []};
js_params(I) -> I.
