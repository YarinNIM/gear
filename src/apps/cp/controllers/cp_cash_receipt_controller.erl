-module(cp_cash_receipt_controller).
-export([
    get_cash_receipts_action/3,
    get_cash_receipt_action/3,
    insert_cash_receipt_action/3
]).

get_cash_receipts_action(Req, State, _) ->
    {_Sid, Cid, _Aid} = cp_app:get_ids(State),
    Crs = cash_receipt_model:get_cash_receipts(#{
        where => #{
            company_id => Cid   
        }
    }),
    Res = #{
        error => false,
        cash_receipts => Crs
    },
    {Res, Req, State}.

get_cash_receipt_action(Req, State, _)->
    #{id:= Id} = cowboy_req:match_qs([{id,int}], Req),
    Res = #{
        error => false,
        cash_receipt => cash_receipt_model:get_cash_receipt_detail(Id)
    },
    {Res, Req, State}.

get_value(K,M) -> 
    {ok, V} = maps:find(K, M),
    V.

validate(Post) ->
    validator:validate(#{
        received_date => {[date_time], <<>>},
        invoice_id => {[int, {min, 1}], <<"Invoice ID is requied">>},
        ref_no => {[int, {min, 1}], <<"Receipt ID is required">>},
        amount => {[float, {min, 0.0001}], <<"Invalid amount">>},
        received_by => {[required], <<"Invalid receiver">>},
        received_from => {[required], <<"Invalid receieved from">>},
        payment_method_id => {[int, {min,1}], <<"Payment method require">>}
    }, Post).

insert_cash_receipt_action(Req, State, _) ->
    #{ body_data:= Post} = State,
    {_, Cid, Aid} = cp_app:get_ids(State),
    Res = case validate(Post) of
        {error, Error } -> {error, Error, form};
        Data -> 
            cash_receipt_model:insert_cash_receipt(
                get_value(invoice_id, Data),
                get_value(amount, Data),
                Data, Cid, Aid
            )
    end,

    Res1 = case Res of
        {error, Emsg, _} -> helper:msg(true, Emsg, form);
        {error, Srv} -> helper:msg(true, Srv, server);
        Cr_id -> #{
            error => false,
            cash_receipt => cash_receipt_model:get_cash_receipt(Cr_id)
        }
    end,
    {Res1, Req, State}.
