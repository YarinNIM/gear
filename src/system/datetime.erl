-module(datetime).
-include("include/datetime.hrl").
-export([get_date/1, get_date/6]).
-export([get_list/0, get_list/1, get_list/2, get_list/3]).
-export([get_list_by_props/1, get_list_by_props/2]).
-export([date_string/1, date_string/2, time_string/1, time_string/2]).
-export([datetime_string/1, datetime_string/2]).
-export([test/0]).

get_date({Y, M, D}) -> get_date(Y, M, D, 0, 0, 0);
get_date({{Y, M, D}}) -> get_date(Y, M, D, 0, 0, 0);
get_date({{Y, M, D}, {H, Mi, S}}) -> get_date(Y, M, D, H, Mi, S).
get_date(Y, M, D, H, Mi, S) -> {{Y, M, D}, {H, Mi, type:to_integer(S)}}.

get_list() -> get_list(month).
get_list(L) when is_atom(L) -> get_list(L, false).
get_list(L, Long) -> get_list( L, Long, en).
get_list(month, true, en) -> ?LONG_MONTHS;
get_list(month, false, en) -> ?SHORT_MONTHS;
get_list(week, true, en) -> ?LONG_WEEKS;
get_list(week, false, en) -> ?SHORT_WEEKS;
get_list(time, _, en) -> ?TIMES;
get_list(month,  _, kh) -> to_unicode(?MONTH_KH);
get_list(week, _, kh) -> to_unicode(?WEEK_KH);
get_list(time, _, kh) -> to_unicode(?TIME_KH);
get_list(digit, _, _) -> to_unicode(?DIGIT_KH);
get_list(_, _, _) -> [].

to_unicode(L) -> [unicode:characters_to_binary(Item, utf8) || Item <- L].

get_list_by_props(L) -> get_list_by_props(L, []).
get_list_by_props(L, Props) ->
    Lang = case lists:member(kh, Props) of
        false -> en;
        _ -> kh
    end,

    Long = lists:member(true, Props),
    get_list(L, Long, Lang).


%% @doc Returns date as date string
date_string(Date) -> date_string(Date, []).
date_string(Date, Props)->
    {{Y, M, D}, _} = get_date(Date),
    Yb = type:to_binary(Y),
    Db = add_zero(D),
    List = get_list_by_props(month, Props),
    Mn = lists:nth(M, List),
    Str = <<Db/binary, "-", Mn/binary,"-", Yb/binary>>,
    case lists:member(kh, Props) of
        true -> to_kh(Str);
        _ -> Str
    end.

time_string(Date) -> time_string(Date, []).
time_string(Date, Props) ->
    {_, {H, M, S}} = get_date(Date),
    Mb = add_zero(M),
    Sb = add_zero(S),
    [Am, Pm] = get_list_by_props(time, Props),
    Suf = case H < 13 of 
        true -> Am;
        _ -> Pm
    end,

    H1 = case H < 13 of
        true -> H;
        _ -> H - 12
    end,
    Hb = add_zero(H1),

    Str = <<Hb/binary,":", Mb/binary,":", Sb/binary," ", Suf/binary>>,
    case lists:member(kh, Props) of
        true -> to_kh(Str);
        _ -> Str
    end.

datetime_string(Date) -> datetime_string(Date, []).
datetime_string(Date, Props) ->
    Dateb = date_string(Date, Props),
    Time = time_string(Date, Props),
    <<Dateb/binary, " ", Time/binary>>.
    
add_zero(N) -> 
    case N < 10 of
        true ->
            Nb = type:to_binary(N),
            <<"0", Nb/binary>>;
        _ ->
            type:to_binary(N)
    end.

to_kh(Str) -> to_kh(Str, lists:seq(0,9)).
to_kh(Str, []) -> Str;
to_kh(Str, [H|T]) ->
    Digits = get_list(digit, true, kh),
    Hb = type:to_binary(H),
    Hu = lists:nth(H+1, Digits),
    Str1 = re:replace(Str, Hb, Hu,[global, {return, binary}]),
    to_kh(Str1, T).

test() -> to_kh(<<"12-Feb-2016">>).

