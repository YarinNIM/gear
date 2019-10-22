%% @author Yarin NIM, <yarin.nim@gmail.com>
%% @copyright Bonghom@2016
%% @doc .. This is sub module for validator for validating
%%
-module(validator_file).
-export([validate/2, validate/3]).
-author('Yarin NIM, <yarin.nim@gmail.com>').
-copyright('Bongthom@2016').
-vsn('0.1').
-doc(<<"This module is sub module of validator for validating file">>).

-define(VAL(K,L), proplists:get_value(K, L)).
-define(VAL(K, L, D), proplists:get_value(K, L, D)).

%% @doc This function will return empty list or list of error messages
%-spec validate(any(), tuple()) -> binary() | [].
%-spec validate(any(), tuple(), binary()) -> binary() | [].


validate(F, {max_size, Size}) -> validate(F, {max_size, Size}, "Exceed the maximum allowed size: " ++ type:to_list(Size) ++ "B");
validate(F, {min_size, Size}) -> validate(F, {min_size, Size}, "Size is lower than " ++ type:to_list(Size) ++ "B");
validate(F, {extensions, Exts}) -> 
    A = type:to_list(list:concate(Exts, " ")),
    validate(F, {extensions, Exts}, "Only these extenstions allowed "++ A);

validate(F, {max_size, Size, Msg}) -> validate(F, {max_size, Size}, Msg);
validate(F, {min_size, Size, Msg}) -> validate(F, {min_size, Size}, Msg);
validate(F, {extensions, Exts, Msg}) -> validate(F, {extensions, Exts}, Msg);
validate(_, _) -> [].


validate(F, {max_size, Size}, Msg) -> 
    S = ?VAL(size, F),
    if
        S > Size -> Msg;
        true -> []
    end;
validate(F, {extensions, Exts}, Msg) ->
    Ext = ?VAL(extension, F),
    case lists:member(Ext, Exts) of
        true -> [];
        _ -> Msg
    end;
validate(_, _, _) -> [].




