%%
%% @author Yarin NIM, yarin.nim@gmail.com
%% @copyright Yarin NIM@2018
%% @doc This module is the interface
%% to encrypt and hash the string.
%%

-module(crypt).
-include("../config/crypt.hrl").
-export([
    to_hex/1, get_config/0,
    hmac/1, hmac/2, hmac/3,
    hash/2
]).
 
hmac(P) -> 
    #{algo:= Algo, secret_key:= Key} = ?CONF,
    hmac(Algo, Key, P).
hmac(Algo, P) -> 
    #{secret_key:= Key} = ?CONF,
    hmac(Algo, Key, P).
hmac(T, K, D) ->
    H = crypto:hmac(T, K, type:to_binary(D)),
    to_hex(H).

hash(P, State) ->
    K = config:item(encryption_key, State),
    hmac(sha256, K, P).


to_hex(L) when not is_list(L) -> to_hex(binary_to_list(L));
to_hex(L) ->
    L1 = lists:flatten(list_to_hex(L)),
    list_to_binary(L1).
    
list_to_hex(L) -> lists:map(fun(X) -> int_to_hex(X) end, L).
 
int_to_hex(N) when N < 256 -> [hex(N div 16), hex(N rem 16)].
 
hex(N) when N < 10 -> $0+N;
hex(N) when N >= 10, N < 16 -> $a + (N-10).

get_config() -> ?CONF.
