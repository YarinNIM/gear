-module(erlcaptcha).
-export([convert/1, convert/2]).
-export([file_name/0]).
-export([validate/2]).

-export([generate_key/0]).
-define(PROPS, [
    {width, <<"150">>},
    {height, <<"50">>},
    {background, <<"#EAEAEA">>},
    {fill, <<"#000000">>},
    {gravity, <<"Center">>},
    %% {font, <<"FreeSansB">>},
    {font, <<"arial">>},
    {fontsize, <<"25">>},
    {wave, <<"-10">>}]).

convert(SID)-> erlcaptcha:convert(SID, ?PROPS).
convert(SID, Props)->
    Key = generate_key(),
    F = file_name(),
    L = merge(Props, ?PROPS),
    Opts = get_options(L),
    Hash = type:to_binary(erlang:system_time()), 
    Cmd = <<"convert ", Opts/binary, " label:\"", Key/binary, "\" ", F/binary>>,
    os:cmd(binary_to_list(Cmd)),
    {ok, Data} = file:read_file(F),
    session:set(captcha, [{key, Key}, {has, Hash}], SID),
    io:format(' - Generating Captcha...~n'),
    {Key, Hash, Data}.

%   case os:cmd(binary_to_list(Cmd)) of
%       [] ->
%           {ok, Data} = file:read_file(F),
%           %file:delete(F),
%           session:set(captcha, [{key, Key}, {has, Hash}], SID),
%           io:format(' - Generating Captcha...~n'),
%           {Key, Hash, Data};
%       Msg -> {error, Msg}
%   end.

generate_key ()->
    Key = "AaBbCcDdEeFfGgHhJjKkMmNnPpQqRrSsTtUuVvWwXxYyZz123456789#",
    L = length(Key),
    rand:seed(exs64),
    list_to_binary([ lists:nth(rand:uniform(L),Key) || _ <- lists:seq(1,5)]).

merge([], D) -> D;
merge([H= {K, _} | T], D) ->
    D1 = list:delete(K, D),
    D2 = list:set(H, D1),
    merge(T, D2).

get_options(Props) ->
    [W, H, Bg, Fill, Grv, Font, FS, Wv] = list:get_value([width, height, background, fill, gravity, font, fontsize, wave], Props),
    S = <<W/binary, "x", H/binary>>,
    W1 = integer_to_binary(binary_to_integer(W)*2),
    Wave = <<" -wave \"",Wv/binary, "x", W1/binary, "\" -crop \"", S/binary, "+0", Wv/binary, "\"">>,
    <<Wave/binary, " -size \"", S/binary, "\" -background \"", Bg/binary, "\" -fill \"", Fill/binary, "\" -gravity \"", Grv/binary, "\" -font \"", Font/binary, "\" -pointsize \"", FS/binary,"\"">>.
    
file_name()->
    F = integer_to_binary(erlang:system_time()),
    <<"/tmp/captcha_", F/binary,".jpg">>.

validate(Key, SID) when is_binary(Key) ->
    Cap = session:get(captcha, SID),
    SKey = list:get_value(key, Cap),
    compare_key(Key, SKey);
validate(PD, SD)->
    P_hash = proplists:get_value(<<"captchaHash">>, PD),
    P_key = proplists:get_value(<<"captchaKey">>, PD),
    S_hash = proplists:get_value(hash, SD),
    S_key = proplists:get_value(key, SD),
    compare_key([P_hash, S_hash],[P_key, S_key]).

compare_key(A, A) when is_binary(A) -> true;
compare_key([Ka, Ka], [Kb,Kb])-> true;
compare_key(_,_)-> false.
