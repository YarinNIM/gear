drop view view_invoice;
create view view_invoice as
select 
    inv.id, inv.invoice_no, inv.service_id, inv.invoice_type, 
    inv.discount, inv.invoice_date, inv.company_id,
    inv.created_date, inv.description,

    inv_amount.amount,

    fun_invoice_amount(
        inv_amount.amount, 
        inv.discount, inv.vat
    ) as total,

    cash_receipt.amount as cash_receipt,

    inv.customer_id, concat(account.first_name, ' ',account.last_name) as customer_name,
    comp.name_en as company_en, inv.customer_company_id

from invoice inv inner join account on inv.customer_id = account.id
    inner join view_invoice_amount inv_amount on inv_amount.invoice_id = inv.id
    left outer join company comp on inv.customer_company_id = comp.id
    left outer join view_invoice_cash_receipt cash_receipt on cash_receipt.invoice_id = inv.id;
