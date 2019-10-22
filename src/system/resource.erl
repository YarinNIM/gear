%% @author Yarin NIM, yarin.nim@gmail.com
%% @copyright 2018 Yarin NIM
%% @version 0.2
%% @title Resource Management
%%
%% @doc The resouce module is to pass and render
%% resource parameter to template
%%
%% The requiured parameters are
%% @param 

-module(resource).

-export([
    js/2,
     map_val/2, map_val/3,
     render/2, render/3, render/4, 
     render_page/2, render_page/3, render_page/4
]).
-define(V(K,P), proplists:get_value(K,P)).
-define(V(K,P, D), proplists:get_value(K,P, D)).
-define(RES(K, V), ?KEY(K, ?KEY(resource, V), [])).
-define(TEMPLATE, #{
    meta_data => resource_meta_data,
    resource => resource,
    page => resource_page}).



%% @doc the Application State
%% @private
-type app_state()::term().
-type cowboy_req()::term().
-type template()::atom().

%% @doc Return the maps value
%% from specific key
map_val(K,M) -> map_val(K,M, #{}).
map_val(K,M, D) ->
    case maps:find(K, M) of
        error -> D;
        {ok, V} -> V
    end.

%% @doc Return the application environment,
%% returns true if the  application in production mode
%% otherwise returns false
%% @private
-spec is_production(app_state()) -> boolean().
is_production(State) -> 
    #{config := Conf} = State,
    #{is_production := IP} = Conf,
    IP.


%% @doc As the framework can handle many application 
%% including sup-application, so it need to know 
%% the right application resource.
%% @private
-spec app_name(app_state()) -> atom().
app_name(State) ->
    #{app := App_opts} = State,
    proplists:get_value(app, App_opts).


%% @doc Render each items map and
%% return the list of resource as list
render_items([], _S) -> [];
render_items(L, State) ->
    Param = #{ base_url => config:base_url(State) },
    [template:render(Item, Param) || Item <- L].

%% @deprecated
%% @doc Render the resource template into binary.
%%
%% @param Param is prolists with the follong required properties:
%%  - css => [{name::atom(), url::list()},..]
%%  - js => [{name::atom(), url::list()}],
%%  - global_js => [binary()]
%%  - on_script_loaded => [binary()]
%%  - variables => [bianry()]
%%  - state => app_state()
%%  - query_string -> [{K, V}, ..]
-spec render(cowboy_req(), app_state()) -> binary().
-spec render(term(), cowboy_req(), app_state()) -> binary().
-spec render(term(), cowboy_req(), app_state(), template()) -> binary().
render(Req, State) -> render([], Req, State).
render(Param, Req, State) -> 
    Page = get_template(resource, State),
    render(Param, Req, State, Page).
    
render(Param, Req, State, Page) ->
    App_name = app_name(State),
    Resource = App_name:resource(),
    Is_pro = is_production(State),
    Base_url = config:base_url(State),
    #{ vsn := Vsn } = Resource,

    Params = #{ 
        vsn =>  Vsn,
        csss => css(Resource, Param, State),
        js => js(Resource, Param, State),
        on_script_loaded => map_val(on_script_loaded,Param, []),
        state => State,
        config=> maps:to_list(config:app_config(State)),
        query_string => query_string(Req),
        base_url => Base_url,
        is_production => Is_pro
    },

    Params1 = Params#{ base_url => config:base_url(State) },
    template:render(Page, Params1).

%% @doc Returns CSS list, the css list is from application resource
%% merged with css defined in page render.
css(Resource, Param, State) ->
    Css = map_val(css, Resource, []) ++ map_val(css, Param, []),
    render_items(Css, State).
    %maps:to_list(Css).

    %merge_production(Css, Is_pro).
%compact(Css, State, {<<"style">>, <<".css">>}) ++ compact(Page_css, State).


%% @doc Adds js object into page. The javascript has 3 levels (
%% preload, init and page) while the preload and init are defined
%% in the application resource and page is defined in each page request.
%%
%% - preload: Loaded as inline embeded at the topmost of the page right after <meta> tag
%% - init: Loads the javascript files in the group right after the document resouce loaded document.onReady
%% - page: Define the javascript required to run for each page
js(Resource, Param) -> js(Resource, Param, #{}).
js(Resource, Params,State) ->
    JSs = map_val(js, Resource, []),
    Preload = map_val(preload, JSs, []),
    Init = map_val(init, JSs, []) ++ map_val(init_js, Params, []),
    %Init = map_val(init, JSs, #{}),
    %Init_ext = map_val(init_js, Param, #{}),
    Page = map_val(js, Params, []),
    [   
     {preload, render_items(Preload, State)},
     {init, render_items(Init, State)},
     {page, render_items(Page, State)}
    ].

    %% %% [
    %%  {preload, Preload},
    %%  {init, Init ++ Init_ext},
    %%  {page, Page}
    %% ].



%% @doc Adds query string to and object 
query_string(Req) -> cowboy_req:parse_qs(Req).

%% @doc Return template to be used 
%% for render content into.
-spec get_template(map()) -> map().
get_template(S) ->
    Ap = app_name(S),
    Res = Ap:resource(),
    Tmp = map_val(template, Res, #{}),
    maps:merge(?TEMPLATE, Tmp).

%% @doc Return a template
-spec get_template(atom(), map()) -> atom().
get_template(K, S) ->
    T = get_template(S),
    map_val(K, T, undefined).

%% @doc Clears resource configuration
-spec clear_resource(map(), list()) -> map().
clear_resource(Res, []) -> Res;
clear_resource(Res, [H|T]) ->
    Res1 = maps:remove(H, Res),
    clear_resource(Res1, T).

%% @doc Renders the resource layout into 
%% page layout, default default_layout
-spec render_page(cowboy_req(), app_state()) -> binary().
-spec render_page(term(), cowboy_req(), app_state()) -> binary().
-spec render_page(term(), cowboy_req(), app_state(), map()) -> binary().
render_page(R, S) -> render_page([], R, S).
render_page(P, R, S) -> 
    Layout = get_template(S),
    render_page(P, R, S, Layout).
render_page(Props, Req, State, L) ->
    %% What to remove, css, js, js_var, on_script_loaded
    Def = get_template(State),
    Layout = maps:merge(Def, L),

    App = app_name(State),

    %% clear these parameter before passing to the template
    Tmp = clear_resource(Props, [js, css, on_script_loaded, meta_data, js_var]),
    Params = #{
        resource => render(Props, Req, State, map_val(resource, Layout)),
        meta_data => meta_data(Props, App, map_val(meta_data, Layout))
    },

    Html = template:render(map_val(page, Layout), maps:merge(Params, Tmp)),
    #{config := Config } = State,
    #{is_production := Is_pro} = Config,
    case Is_pro of
        true -> 
            Html1 = re:replace(Html, <<"[\\n]*">>, <<"">>, [{return, binary}, global]),
            Html2 = re:replace(Html1, <<"\\s{2,}">>, <<" ">>, [{return, binary}, global]),
            re:replace(Html2, <<"\\},\\}">>, <<"}}">>, [{return, binary}, global]);
        _ -> Html
    end.

%% @doc Gets the meta-data passed by application
%% and merge with extra field from default meta-data 
%% in app/config/meta_data
meta_data(Param, App, Layout) ->
    Def = App:meta_data(),
    Meta = map_val(meta_data, Param),
    template:render(Layout, maps:merge(Def, Meta)).
