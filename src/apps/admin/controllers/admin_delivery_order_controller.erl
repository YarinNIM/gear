%% @author Yarin NIM <yarin.nim@gmail.com>
%% @copyright 2019 Yarin NIM
%% @version 0.1
%% @title Delivery Order Controller
%% @doc Description about documentation

-module(admin_delivery_order_controller).
-export([ 
    get_orders_action/3
]).

get_orders_action(Rq, St, _) ->
    Rs = #{
        error => false,
        orders => delivery_order_model:get_orders()
    },

    {Rs, Rq, St}.
