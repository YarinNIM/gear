%% @author Yarin NIM <yarin.nim@gmail.com>
%% @copyright 2019 Yarin NIM
%% @version 0.1
%% @title Delivery Order Controller
%% @doc Manage account delivery order
-module(account_delivery_order_controller).
-export([
    get_orders_action/3, get_order_action/3
]).

get_orders_action(Rq, St, _) ->
    #{account_id:= Aid} = St,
    Rs = #{ 
        error => false,
        orders => delivery_order_model:get_orders(#{<<"orders.account_id">> => Aid})
    },
    {Rs, Rq, St}.

get_order_action(Rq, St, _) ->
    #{ delivery_order_id:= Id} = cowboy_req:match_qs([{delivery_order_id, int}], Rq),
    Rs =  delivery_order_model:get_order_detail(Id),
    {Rs, Rq, St}.
