%%
%% @author Yarin NIM, yarin.nim@gmail.com
%% @copyright Yarin NIM@2018
%% @doc This module to handle the system 
%% configuration
%%
-module(config).
-include("../config/config.hrl").

-type app_state()::term().
-export([
    parent_url/1, parent_url/2, base_url/1, base_url/2,
    locale_url/2, locale_url/3,
    crypt/0, crypt/1, crypt/2

    %%  path/0,path/1, path/2,
    %%external_app/0,external_app/1
]).
-export([event_listener/0, event_listener/1]).
-export([system_sup/0]).

-export([
    app/0, app/1,app/2, app/3,
    db/0, db/1, db/2, db_default_pool/0,
    % db_record_size/0,
    email/0, email/1, email/2,
    session/0, session/1,
    get_dispatch/0,app_static/1,
    cors/0, cors/1, cors/2,

    server/0, server/1, server/2
]).

%% @doc Return the maps value
%% from specific key
map_val(K,M) -> map_val(K,M, undefined).
map_val(K,M, D) ->
    case maps:find(K, M) of
        error -> D;
        {ok, V} -> V
    end.

parent_url(State) -> parent_url(<<"">>, State).
parent_url(U, S) when is_list(U) -> parent_url(type:to_binary(U), S);
parent_url(U, S) ->
    #{ app := App_opts} = S,
    case proplists:get_value(prefix, App_opts) of
        undefined -> base_url(S);
        Pre ->
            Pref = type:to_binary(Pre),
            Base = config:base_url(S),
            Re = re:replace(Base, <<Pref/binary, "/$">>, <<"">>),
            Re1 = iolist_to_binary(Re),
            <<Re1/binary, U/binary>>
    end.

base_url(State) -> base_url(<<"">>, State).
base_url(U, S) when is_list(U) -> base_url(type:to_binary(U), S);
base_url(U, S) ->
    #{base_url := Base_url} = S,
    <<Base_url/binary, U/binary>>.

%% @doc Return the prividied URL with extra value
%% _lang and plus extend
-spec locale_url(binary(), app_state()) -> binary().
-spec locale_url(binary(), app_state(), map()) -> binary().
locale_url(U, S) -> locale_url(U, S, #{prefix => "locale", extension => "js"}).
locale_url(U, State, Options) ->
    Url = type:to_list(U),
    Prefix = type:to_list(map_val(prefix, Options, "")),
    Ext = type:to_list(map_val(extension, Options, "")),
    #{lang := Lang} = State,
    base_url(Prefix ++ "/" ++ type:to_list(Lang) ++"/"++ Url++"."++ Ext, State).
    

db() -> ?DB.
db(P) -> map_val(P,?DB).
db(K,P) -> 
    Db = map_val(P, ?DB),
    map_val(K, Db).

db_default_pool() -> ?DB_DEFAULT_POOL.
% db_record_size() -> ?DB_RECORD_SIZE.
    
session() -> ?SESSION.
session(K) -> map_val(K, ?SESSION).

%% Get the application configration
app() -> ?APP.
app(App) -> map_val(App, ?APP,[]).
app(A, K) -> app(A, K, undefined).
app(A, K, D) ->
    App = app(A),
    map_val(K, App, D).

%% Gets the email configuration
email() -> ?EMAILS.
email(E) -> map_val(E, ?EMAILS,[]).
email(E, K) ->
    Email = email(E),
    map_val(K, Email).

app_static(App) ->
    Static = config:app(App, static),
    [{P, cowboy_static, Op} || {P, Op } <- Static].

get_dispatch() ->
    Apps = maps:to_list(config:app()),
    lists:map(fun({App, _}) ->
        Domain = config:app(App, domain),
        Handler = config:app(App, handler),
        Static = config:app_static(App),
        Path = Static ++ [{
            {"/", Handler,[]},
            {"/[...]", Handler, []}
        }],
        {Domain, Path}
    end, Apps).

%%
%path() -> ?PATH.
%path(P) -> path(P, "").
%path(P, E) -> map_val(P, ?PATH,"") ++ type:to_list(E).

%external_app() -> map_val(external_app, ?PATH).
%external_app(A) ->
%   Path = map_val(external_app,?PATH),
%   map_val(A, Path).
%
event_listener() -> ?EVENT_LISTENER.
event_listener(E) -> map_val(E, event_listener()).

system_sup() -> ?SYSTEM_SUP.

cors() -> ?CORS.
cors(default) ->
    #{ default := Def } = ?CORS,
    map_val(Def, ?CORS);
cors(C) -> map_val(C, cors()).
cors(K, C) -> 
    Cors = cors(C),
    map_val(K, Cors).

server() -> ?SERVER.
server(K) -> server(K, <<>>).
server(K, D) -> map_val(K, server(), D).

crypt() -> ?CRYPT.
crypt(K) -> crypt(K, undefined).
crypt(K, D) -> map_val(K, ?CRYPT, D).
