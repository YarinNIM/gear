%% @author Yarin NIM, yarin.nim@gmail.
%% @doc HTTP Client is the HTTP Client
%% to make request through HTTP protocole
%%
-module(http_client).
-export([
    map_value/2,
    cors_request/2, cors_request/3
]).

-define(V(K,L), proplists:get_value(K, L)).
-define(V(K, L, D), proplists:get_value(K, L, D)).

-type cowboy_req()::term().
-type app_state()::term().


%% @doc Gets map value, request default
%% if the key is not found in the map
map_value(K, M) -> map_value(K, M, []).
map_value(K, M, D) ->
    case maps:find(K, M) of
        error -> D;
        {ok, V} -> V
    end.

%% @doc Convert map to proplists
%% and wrap each key values into http string
map_to_http_list(M) ->
    lists:map(fun({K, V})->
        {type:to_list(K), type:to_list(V)}
    end, maps:to_list(M)).


%% @doc Return the default cors information
%% merged with cors inforation from Pamamter
-spec which_cors([list()], map()) -> {string(), [tuple()], [tuple()]}.
which_cors(Post, Params) ->
    %% Cors_1 = ?V(<<"cors">>, Post, config:cors(default)),
    Cors_1 = ?V(<<"cors">>, Post, default),
    Cors = config:cors(type:to_atom(Cors_1)),
    #{ headers := Hds } = Cors,
    #{ options := Opt } = Cors,
    #{ url := Url} = Cors,

    P_url = ?V(<<"url">>, Post, <<"">>),
    Headers = maps:merge(Hds, map_value(headers, Params, #{})),
    Options = maps:merge(Opt, map_value(options, Params, #{})),
    {Url ++ type:to_list(P_url), map_to_http_list(Headers), maps:to_list(Options)}.

content_type(json) -> "application/json";
content_type(url_encoded) -> "application/x-www-form-urlencoded";
content_type(form_data)->
    B = type:to_list(uid:get_id()),
    {B, "multipart/form-data; boundary=" ++ B}.

%% @doc Which method is set to use in 
%% the cors request
method(Post) ->
    M = ?V(<<"method">>, Post, <<"get">>),
    type:to_atom(string:lowercase(M)).

%% @doc Escape the content response from cors
escape(Req, Res) ->
    case request:media_type(Req) of
        {<<"application">>, <<"json">>, _} -> 
            try jsx:decode(Res)
            catch _:_ -> #{response => Res} end;
        {<<"text">>, <<"html">>, _} -> Res;
        _ -> Res
    end.

%% @doc If the posted field is an array.
%% data treated as array is data which has the at sign (@)
%% that the end of paramater name
%% eg. students@
%% <input type="checkbox" name="student@" value="data" />
is_array_field(K) -> 
    case re:replace(K, <<"@$">>, <<"">>) of
        [K1,_] -> K1;
        _ -> false 
    end.
    
%% @doc Transform propslist posted data into
%% HTTP Query string data to put into body
post_data(Post) ->
    Data = lists:map(fun({K, V}) ->
        V1 = http_uri:encode(V),
        case is_array_field(K) of
            false -> type:to_list(<<K/binary,"=", V1/binary>>);
            K1 -> type:to_list(<<K1/binary,"[]=", V1/binary>>)
        end
    end, Post),
    string:join(Data, "&").

%% @doc Cros Origin Resource Share allow the request from
%% client and passes the request data to another HTTP server.
-spec cors_request(cowboy_req(), app_state()) -> {term(), cowboy_req(), app_state()}.
-spec cors_request(cowboy_req(), app_state(), map()) -> {term(), cowboy_req(), app_state()}.
cors_request(R, S) -> cors_request(R, S, #{}).
cors_request(Req, State, Params) ->
    #{body_data := Post} = State,
    {Url, Headers, Options } = which_cors(Post, Params),

    Method = method(Post),
    Request = case Method of
        get -> {Url, Headers};
        _  -> 
            {Headers_1, Content_type, Data} = case request:is_multipart_request(Req) of
                false -> {[], content_type(url_encoded), post_data(Post)};
                true -> multipart_formdata(Post)
            end,
            {Url, Headers ++ Headers_1, Content_type, Data }
    end,

    Res = case httpc:request(Method, Request, Options,[]) of
        {ok, {_status, _, Http_Res}} -> escape(Req, type:to_binary(Http_Res));
        {error, Error} -> Error;
        Else -> Else
    end,
    {Res, Req, State}.

%% @doc Returns turple of HTTP Form parameter list
%% and uploaded file list
multipart_data(Post) ->
    lists:foldr(fun(Item = {K, V}, {Form, Files}) ->
        case is_map(V) of
            true -> 
                #{tmp_name := File} = V,
                {Form, Files#{K => File}};
            _ -> {Form ++ [Item], Files}
        end
    end, {[], #{}},Post).




%% @doc Returns multipart form data
multipart_formdata(Post) -> 
    {Data, Files} = multipart_data(Post),
    Boun = type:to_list(uid:get_id()),
    New_line = <<"\r\n">>,
    Data_1 = lists:foldl(fun({K, V}, In) ->
        [In, "--", Boun, New_line, "Content-Disposition: form-data; name=\"", type:to_list(K), "\"", New_line, New_line,
         type:to_binary(V), New_line]
    end, <<"">>, Data),
    Data_2 = erlang:iolist_to_binary(Data_1),
    
    Files_1 = maps:fold(fun(Field, File, In) ->
            case file:read_file(File) of
                {error, _} -> <<"">>;
                {ok, Content} ->
                    erlang:iolist_to_binary([In, "--", Boun, New_line, 
                        "Content-Disposition: form-data; name=\"", type:to_binary(Field), "\"; filename=\"", File,"\"", New_line,
                        "Content-Type: ", file_info:mimetype(File), New_line, New_line, Content, New_line
                    ])
            end
    end, <<"">>, Files),
    Body = type:to_list(erlang:iolist_to_binary([Data_2, Files_1, "--", Boun,"--", New_line])),
    Content_type = "multipart/form-data; boundary="++ Boun,
    Headers = [{"Content-Length", integer_to_list(length(Body))}],
    {Headers, Content_type, Body}.
