-module(helper).
-export([
    join_list/1, join_list/2,
    find/2, find/3, msg/2, msg/3,
    handle/1, handle/2, 
    substract_map/2, method_exists/2,

    test/0
]).

join_list(L) -> join_list(L, <<",">>).
join_list(L, S) ->
    L1 = [type:to_binary(I) || I <- L],
    erlang:list_to_binary(lists:join(S, L1)).


find(K, L) -> find(K, L, undefined).
find(K, M, D) when is_map(M) ->
    case maps:find(K, M) of
        error -> D;
        {ok, V} -> V
    end;
find(K, L, D) when is_list(L) ->
    case lists:keyfind(K, 1, L) of
        false -> D;
        {_, V} -> V
    end.

msg(E, M) -> msg(E, M, form).
msg(E, M, T) -> #{
    error => E,
    msg => M,
    type => T
}.

%% @doc This function will handle function call
%% with provided parameter returned from first execution.
%% Once, it meets the {error, binary()}, it stop precessing the 
%% next function(s)
-spec handle(Func::list()) -> {error, Msg::binary()} | any().
handle(F) -> handle(F, #{}).
handle({E, F}, P) ->
    case F(P) of
        {error, Msg} -> {error, Msg, E};
        Data -> Data
    end;
handle(F, P) when is_function(F) -> handle({error, F}, P);
handle([], P) -> P;
handle([H|T], Params) -> 
    case handle(H, Params) of
        Error = {error, _,_} -> Error;
        Else -> handle(T, Else)
    end.

%% @doc Substract only some elements from a map
substract_map(L, M) ->
    lists:foldl(fun(Item, M1) ->
        case maps:find(Item, M) of
            error -> M1;
            {ok, V} -> M1#{Item => V}
        end
    end, #{}, L).

%% @doc Return boolean value indicates if
%% the provided module and method exists
-spec method_exists(atom(), atom()) -> true | false.
method_exists(Module, Method) ->
    Info = Module:module_info(),
    Exps = proplists:get_value(exports, Info),
    case proplists:get_value(Method, Exps) of
        undefined -> false;
        _ -> true
    end.

    
%% @doc Testing
test()->
    Funs = [
        {form, fun(_) -> fist end},
        {form, fun(_) -> second end},
        {server, fun(_) -> {error, <<"Error occurs">>} end},
        fun(_) -> final end
    ],
    handle(Funs, <<"good">>).

