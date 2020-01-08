%% @author Yarin NIM <yarin.nim@gmail.com>
%% @copyright 2019
%% @doc This is helper module to support the
%% route configuration and actions.

-module(route_helper).
-define(HANDLER, toppage_handler).
-export([
    static_routes/1,
    routes/0
]).

map_val(K,M) -> map_val(K,M, undefined).
map_val(K,M, D) ->
    case maps:find(K, M) of
        error -> D;
        {ok, V} -> V
    end.

%% Get the static application configuration
%% including sub application static route
static_routes(App) ->
    {Location, Dirs} = config:app(App, static, {<<"">>, []}),
    [{<<"/", Dir/binary, "/[...]">>, cowboy_static, {dir, <<Location/binary, "/", Dir/binary>>}} || Dir <- Dirs] ++
    [{ <<"/favicon.ico">>, cowboy_static, {file, <<Location/binary, "favicon.icon">>}}].


%% @doc Get sub applications and add to the handler
sub_apps(App) ->
    Sub = config:app(App, sub_apps, []),
    sub_apps(Sub, []).
sub_apps([], Apps) -> Apps;
sub_apps([{Prefix, App} | T], Apps) ->
    Base = type:to_binary("/" ++ type:to_list(Prefix) ++ "/"),
    Pref1 = type:to_list(Prefix),
    %Static = sub_static({Prefix, App}),
    %Apps1 = Apps ++ Static ++ [
    Apps1 = Apps ++ [
        {<<Base/binary, "[...]">>, ?HANDLER, [{app, App}, {prefix, Pref1}]}
    ], sub_apps(T, Apps1).

%% Get the list of applications which defined 
%% with domain.
with_domain(Apps) -> with_domain(Apps, []).
with_domain([], Apps) -> Apps;
with_domain([App = {_, Conf} | T], Apps_wd) ->
    case map_val(domain, Conf) of
        undefined -> with_domain(T, Apps_wd);
        _ -> with_domain(T, Apps_wd ++ [App])
    end.

%%
routes() ->
    Apps = maps:to_list(config:app()),
    io:format('App: ~p~n',[Apps]),
    Apps_wd = with_domain(Apps),
    lists:map(fun({App, _}) ->
        Domain = config:app(App, domain),
        Path = [{"/", ?HANDLER, #{app => App}}]
            ++ static_routes(App)
            ++ sub_apps(App)
            ++ [{"/[...]", ?HANDLER, #{app => App}}],
        {Domain, Path}
    end, Apps_wd).


