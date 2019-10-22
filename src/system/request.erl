
-module(request).
-export([
    get/1, get/2, cookie/2,
    info/2,host/1, 
    headers/1, media_type/1, method/1, peer/1, ref/1, scheme/1, http_version/1, path_info/1,
    content_type/1, content_length/1, cookie/1, referer/1, user_agent/1,

    is_multipart_request/1
]).
-define(V(K,L), proplists:get_value(K, L)).

get(Req) -> cowboy_req:parse_qs(Req).
get(K, R) -> ?V(K, cowboy_req:parse_qs(R)).

cookie(F, Req) when not is_binary(F) -> cookie(type:to_binary(F), Req);
cookie(F, Req) -> ?V(F, cowboy_req:parse_cookies(Req)).


headers(Req) -> info(headers, Req).
host(Req) -> info(host, Req).
media_type(Req) -> info(media_type, Req).
method(Req)  ->info(method, Req).
path_info(Req) -> info(path_info, Req).
peer(Req) -> info(peer, Req).
ref(Req) -> info(ref, Req).
scheme(Req) -> info(scheme, Req).
http_version(R) -> info(version, R).

content_length(R) -> header_info(<<"content-length">>, R).
content_type(R) -> header_info(<<"content-type">>, R).
cookie(R) ->header_info(<<"cookie">>, R).
referer(R) -> header_info(<<"referer">>, R).
user_agent(R) ->header_info(<<"user-agent">>, R).

is_multipart_request(R) ->
    [T|_] = re:split(content_type(R),<<"/">>),
    case T of
        <<"multipart">> -> true;
        _ -> false
    end.
    
header_info(F, Req) -> 
    Headers = headers(Req),
    #{ F := V} = Headers,
    V.

info(F, Req) -> 
    #{F := V} = Req,
    V.
