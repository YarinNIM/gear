-module(download).
-export([
    raw/2
]).

raw(File, Req) ->
    Mt = file_info:mimetype(File),
    Req1 = cowboy_req:set_resp_headers(#{
        <<"content-type">> => Mt,
        <<"content-encoding">> => <<"gzip">>
    }, Req),
    {ok, Data} = file:read_file(File),
    Req2 = cowboy_req:reply(200, #{}, Data, Req1),
    {Data, Req2}.
