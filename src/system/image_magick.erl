%% @author Yarin NIM, <yarin.nim@gmail.com>
%% @doc This fkdasjflkd aslkfdjasl
%% jfdlsaj flkdjasl;k jflkdajs lfjda;ls fdas klfjda;s ljfdsa fkdjas ;kfdas
%% fdkalsj f;ldjas ;lkfjda;kls fdas
%% <strong>fjdsajfl;dsa jfdjsa</strong>
-module(image_magick).
-define(OP, [{capture, all_but_first, binary}]).
-export([
    image_size/1,
    resize/2, resize/3, resize/4
]).

-spec identify(binary(), binary()) -> binary().
%% @doc Send the identify imagemagick
%% and return string
identify(Str, Img) ->
    Cmd = <<"identify -format \"", Str/binary, "\" ", Img/binary>>,
    os:cmd(type:to_list(Cmd)).

-spec image_size(binary()) -> {W::binary(), H::binary()} | {error, Msg::binary()}.
%% @doc Get the orginal image size
image_size(Path) ->
    Iden = identify(<<"%w %h">>, Path),
    case re:run(Iden, <<"^(\\d+)\\s(\\d+)">>, ?OP) of
        nomatch -> {error, Iden};
        {match, [W, H]} -> {type:to_int(W), type:to_int(H)}
    end.


get_size(M) when is_list(M) -> M;
get_size(M) when is_binary(M) -> type:to_list(M);
get_size(M) when is_integer(M) -> get_size({M , M});
get_size({W, H}) -> type:to_list(W) ++ "x" ++ type:to_list(H).

resize(Img, Size) -> resize(Img, Size, Img).
resize(In, Size, Out) ->  resize(In, Size, Out, false).
resize(In, Size, Out, Bg_proc) ->
    Bg = case Bg_proc of
        true -> " &";
        _ -> ""
    end,

    Si = get_size(Size),
    Cmd = "convert " ++ type:to_list(In) ++
        " -resample 72 " ++
        " -resize " ++ Si ++ "\\> "  ++
        type:to_list(Out) ++ Bg,
    start_port(Cmd).

start_port(Cmd) ->
    Port = erlang:open_port({spawn, Cmd}, [stream, in, eof, hide, exit_status]),
    get_data(Port, []),
    case erlang:port_info(Port) of
        undefined -> ok;
        _ -> erlang:port_close(Port)
    end,
    ok.


get_data(Port, IData) ->
    receive
        {Port, {data, Data}} -> get_data(Port, [Data | IData]);
        {Port, {exit_status, 0}} -> ok
    end.
