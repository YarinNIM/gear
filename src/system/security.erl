-module(security).
-define(V(K,L), proplists:get_value(K,L)).
-define(V(K,L,D), proplists:get_value(K,L,D)).
-export([
     validate/3, generate/2,
     validate_jwt/3
]).

%% @doc Checks if user logged in the 
%% application
has_login(Sid) when is_binary(Sid) ->
    case session:get(has_login, Sid) of
        true -> true;
        _ -> false
    end;
has_login(State) ->
    #{session_id:= Sid} = State,
    has_login(Sid).

validate(Req, State, Csrf) ->
    #{enabled := E} = Csrf,
    case E of
        false -> ok;
        true -> check(Req, State, Csrf);
        _ -> ok
    end.

%% @doc Checks if the posted token name
%% and value matches the store information
%% on the server.
check(Req, State, Csrf) ->
    #{cookie_name := CN, token_name:= TN } = Csrf,
    #{body_data := Post} = State,
    Cookies = cowboy_req:parse_cookies(Req),
    Cs = proplists:get_all_values(type:to_binary(CN), Cookies),
    Token_val = proplists:get_value(TN, Post, none),
    
    case lists:member(Token_val, Cs) of
        true -> ok;
        _ -> {error, <<"Invalid CSRF">>}
    end.

%% @doc Validates the JWT when account is already login.
-spec validate_jwt(atom(), map(), map()) -> {atom(), map(), map()}.
validate_jwt(false, Rq, St) -> {false, Rq, St};
validate_jwt(stop, Rq, St) -> {stop, Rq, St};
validate_jwt(Auth, Req, State) ->
    #{app:= App} = State,
    case has_login(State) of
        true -> 
            get_jwt(proplists:get_value(app, App)),
            %%Req1 = cowboy_req:reply(200,#{<<"error-msg">> => <<"JWT Failed in validation">>},Req),
            {true, Req, State};
        _ -> {Auth, Req, State}
    end.

%% @doc Login using JWT token
%% Not yet implement
-spec get_jwt(term()) -> bool.
get_jwt(_App) -> true.
    %case helper:method_exists(App, jwt) of
    %   false -> true;
    %   _ ->   
    %%      %#{ enabled:= Enabled } = App:jwt(), 
    %       true
    %end.



generate(Req, Csrf) ->
    #{enabled := E } = Csrf,
    case E of
        false -> {ok, Req};
        true -> create(Req, Csrf);
        _ -> {ok, Req}
    end.

cookie_options(Csrf) ->
    Keys = [expires, max_age, domain, path, secure, http_only],
    lists:foldr(fun(K, I) ->
        case maps:find(K, Csrf) of
            error -> I;
            {ok, V} -> I#{K => V}
        end
    end, #{}, Keys).


create(Req, Csrf) ->
    Cookies = cowboy_req:parse_cookies(Req),
    #{cookie_name := C_name} = Csrf,
    Hash = case ?V(C_name, Cookies) of
        undefined -> base64:encode(crypto:strong_rand_bytes(32));
        H -> H
    end,

    #{regenerate := RG } = Csrf,
    Hash_re = case RG of
        true -> base64:encode(crypto:strong_rand_bytes(64));
        _ -> Hash
    end,

    #{token_name:= TN} = Csrf,
    {
        #{name => TN, hash => Hash},
        cowboy_req:set_resp_cookie( C_name, Hash_re, Req, cookie_options(Csrf))
    }.
