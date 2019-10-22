%% @author Yarin NIM <yarin.nim@gmail.com>
%% @copyright 2019 Yarin NIM
%% @version 0.1
%% @title Account Address Controller
%% @doc Manage the addresses created by specific account
-module(account_address_controller).
-export([
    validate/1,
    get_addresses_action/3,
    insert_address_action/3,
    update_address_action/3,
    delete_address_action/3
]).

get_addresses_action(Rq, St, _) ->
    #{ account_id:= Aid} = St,
    Addrs = address_model:get_addresses({<<"address.created_by = $1">>, [Aid]}),
    Rs = #{ error => false, addresses => Addrs},
    {Rs, Rq, St}.

validate(Post) -> validator:validate(#{
        id => {[integer], <<>>},
        address_name => {[required, {minlength, 3}], <<"Name required at least 3 char.">>},
        address => {[required, {minlength, 15}], <<"Address at least 15 Chars.">>},
        village_id => {[integer, {min, 1}], <<"Please select village">>}
    }, Post).

insert_address_action(Rq, St, _) ->
    #{ account_id:= Aid, body_data:= Post} = St,
    Funs = [
        {form, fun(Body) -> validate(Body) end},
        {server, fun(Data) -> address_model:insert_address(Data, Aid) end},
        fun(Addr_id) -> #{ 
            error => false,
            address => address_model:get_address(Addr_id) } 
        end
    ],

    Rs = case helper:handle(Funs, Post) of
        {error, Error, ET} -> helper:msg(true, Error, ET);
        R ->  R
    end,
    {Rs, Rq, St}.

update_address_action(Rq, St, _) ->
    #{ account_id:= Aid, body_data:= Post} = St,

    Funs = [
        {form ,fun(Bdata) -> validate(Bdata) end },
        {server, fun(#{ id:= Ad_id} = Addr) -> 
            address_model:update_address(Ad_id, Addr, Aid)
        end}
    ],

    Res = case helper:handle(Funs, Post) of
        {_, Er, Et} -> helper:msg(true, Er, Et);
        Addr_id -> #{
            error => false,
            address => address_model:get_address(Addr_id)
        }
    end,
    {Res, Rq, St}.

delete_address_action(Rq, St, _) ->
    #{body_data:= Post, account_id:= Aid} = St,
    Id = type:to_integer(proplists:get_value(<<"id">>, Post)),
    Rs = case address_model:delete_address(Id, Aid) of
        {error, Db} -> helper:msg(true, Db, server);
        _ -> #{ error => false}
    end,
    {Rs, Rq, St}.

