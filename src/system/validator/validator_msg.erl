%% @author Yarin NIM, <yarin.nim@gmail>
%% @copyright Bongthom@2016
%% @doc This module to set default message for
%% validator
%%
-module(validator_msg).
-author(<<"Yarin NIM, <yarin.nim@gmail.com">>).
-copyright(<<"Bongthom@2016">>).
-doc(<<"Set default message for Validator">>).

-export([generate/3]).

generate(K, V, R) -> 
    Msg = join(msg(K, V, R)),
    validator:validate_key(V, R, Msg).

msg(K, _, {listsize_max, L}) -> [<<"The maximum list length of">>, key_to_field(K), <<"is">>, L];
msg(K, _, {listsize_min, L}) -> [<<"The minimum list length of">>, key_to_field(K), <<"is">>, L];
msg(K, _, {listsize_range, {L, H}}) -> [<<"The list size is">>, key_to_field(K), <<"is">>, L, <<"to">>, H];
msg(K, _, required) -> [key_to_field(K), <<"is required">>];
msg(K, _, {minlength, L}) -> [key_to_field(K), <<"requires at least">>, L, <<"character long">>];
msg(K, _, {maxlength, L}) -> [key_to_field(K), <<"length exceed">>, L, <<" characters">>];
msg(K, _, {rangelength, {Min, Max}}) -> [key_to_field(K), <<"length must be between">>, Min, <<"and">>, Max];
msg(K, _, {min, V}) -> [key_to_field(K), <<"must be greater than">>, V];
msg(K, _, {max, V}) -> [key_to_field(K), <<"must be lower than">>, V];
msg(K, _, {range, {Min, Max}}) -> [key_to_field(K), <<"must be between">>, Min, <<"and">>, Max];
msg(K, _, email) -> [key_to_field(K), <<"is invalid email address">>];
msg(K, _, phone) -> [key_to_field(K), <<"is invalid phone number">>];
msg(K, _, {equal_to, V}) -> [key_to_field(K), <<"must be equal to">>, V];
msg(K, _, {not_equal_to, V}) -> [key_to_field(K), <<"not be not equal to">>, V];
msg(K, _, password) -> [key_to_field(K), <<"is invalid password format">>];
msg(K, _, {reg, _}) -> [key_to_field(K), <<"does not match the pattern">>].


join([]) -> <<"">>;
join([Msg]) -> type:to_binary(Msg);
join([H|T]) -> 
    lists:foldl(fun(I, In) ->
        Item = type:to_binary(I),
        <<In/binary," ", Item/binary>>
    end, type:to_binary(H), T).

key_to_field({K, _}) -> K;
key_to_field({K, _, _}) -> K;
key_to_field(K) -> K.
