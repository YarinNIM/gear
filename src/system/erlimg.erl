%% @author Yarin NIM, <yarin.nim@gmail.com>
%% @doc This fkdasjflkd aslkfdjasl
%% jfdlsaj flkdjasl;k jflkdajs lfjda;ls fdas klfjda;s ljfdsa fkdjas ;kfdas
%% fdkalsj f;ldjas ;lkfjda;kls fdas
%% <strong>fjdsajfl;dsa jfdjsa</strong>
-module(erlimg).
-export([
    info/1,
    resize/2, resize/3]).

%% Convert binary to integer
to_int(B) -> erlang:binary_to_integer(B).

to_binary(T) when is_binary(T) -> T;
to_binary(T) when is_atom(T) -> erlang:atom_to_binary(T);
to_binary(T) when is_integer(T) -> erlang:integer_to_binary(T);
to_binary(T) when is_list(T) -> erlang:list_to_binary(T).

to_list(T) when is_list(T) -> T;
to_list(T) when is_binary(T) -> erlang:binary_to_list(T).

-type image_field() :: width | height | size | extension | format | number_of_image | file_name | path | full_path | image_size.
-type image_field_value():: integer() | binary().
-type image_info() :: [{image_field(), image_field_value()},...].
-type image_error() :: {error, binary()}.
-type image_size():: {binary(), binary()}.

-spec info(binary()) -> image_info() | image_error().
info(I) ->
    Img = to_binary(I),
    Cmd = <<"identify -format \"%wx%h %b %e %m %n [%f] [%d] %i\" ",Img/binary>>,
    Result = os:cmd(erlang:binary_to_list(Cmd)),
    io:format('~p~n',[Result]),
    Reg = <<"^(\\d+)x(\\d+)\\s(\\w+)\\w*B\\s(\\w+)\\s(\\w+)\\s(\\d+)\\s\\[(.+)\\]\\s\\[(.+)\\]\\s(.+)">>,
    case re:run(Result, Reg, [{capture, all_but_first, binary}]) of
        nomatch -> {error, <<"Cannot identify: ", Img/binary>>};
        {match,[W, H, S, E, F, N, Fn, D, P]} ->
            [
                {width, to_int(W)}, {height, to_int(H)}, {size, to_int(S)},
                {extension, E}, {format, F}, {number_of_images, to_int(N)},
                {file_name, Fn}, {path, D},
                {full_path, P}, {image_size, {to_int(W), to_int(H)}}
            ]
    end.


resize(Img, To_size) -> resize(Img, To_size, Img).

-spec resize(binary(),image_size(), binary()) -> any().
resize(I, To_size, N) ->
    Img = to_binary(I),
    New_name = to_binary(N),
    Info = info(Img),
    io:format('~p~n',[Info]),
    Size = proplists:get_value(image_size, Info),
    {W, _} = aspec_size(Size, To_size),
    W1 = to_binary(W),
    Cmd = <<"convert ",  Img/binary ," -resize " , W1/binary, "x ", New_name/binary>>,
    os:cmd(to_list(Cmd)).

-spec aspec_width(integer(), image_size()) -> image_size().
aspec_width(W1, {W, H}) -> 
    Aspec = W/H,
    H1 = W1 / Aspec,
    {W1, round(H1)}.

-spec aspec_height(integer(), image_size()) -> image_size().
aspec_height(H1, {W, H}) ->
    Aspec = W/H,
    W1 = H1 * Aspec,
    {round(W1), H1}.

-spec aspec_size(image_size(), image_size()) -> image_size().

%% @doc The field will be added
%% fjdla sfjldaj s
%% @
aspec_size(Size, {W1, H1}) -> 
    {W2, H2} = aspec_width(W1, Size),
    case H2 > H1 of
        true -> aspec_height(H1, Size);
        _ -> {W2, H2}
    end.

