-module(cp_invoice_controller).
-export([
    get_invoices_action/3,
    get_detail_action/3, get_cash_receipts_action/3
]).

get_invoices_action(Req, State, _) ->
    {_Sid, Cid, _Aid} = cp_app:get_ids(State),
    Res = #{
        error => false,
        invoices => invoice_model:get_company_invoices(Cid)
    },
    {Res, Req, State}.

company(Id) ->
    Sql = <<"select id, name_en, logo_url, phone_number, email, website from view_company where id = $1">>,
    #{
        detail => db:query_row(Sql,[Id]),
        address => company_model:get_addresses(Id, main_office)
    }.

customer(Inv) ->
    #{ customer_id:= Aid} = Inv,
    Ac = account_model:get_account(Aid),
    Comp = case maps:find(customer_company_id, Inv) of
        error -> #{};
        {ok, Cid} -> 
            io:format('CID: ~p~n',[Cid]),
            company(Cid)
    end,
    Comp#{account => Ac}.

get_detail_action(Req, State, _) ->
    {_Sid, Cid, _Aid} = cp_app:get_ids(State),
    #{ id:= Inv_id} = cowboy_req:match_qs([{id, int}],Req),
    {Inv, Inv_detail} = invoice_model:get_invoice(Inv_id),
    Res = #{
        error => false,
        company => company(Cid),
        invoice => Inv,
        invoice_detail => Inv_detail,
        customer => customer(Inv)
    },

    {Res, Req, State}.

get_cash_receipts_action(Req, State, _) ->
    #{ invoice_id:= Inv_id } = cowboy_req:match_qs([{invoice_id, int}], Req),
    Res = #{
        error => false,
        cash_receipts => invoice_model:get_cash_receipts(Inv_id)
    },
    {Res, Req, State}.
