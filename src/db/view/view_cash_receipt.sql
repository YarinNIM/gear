drop view view_cash_receipt;
create or replace view view_cash_receipt as
    select 
        cr.id, cr.invoice_id, cr.ref_no, cr.amount,cr.received_date,
        inv.company_id, method.name_en as payment_method_en
    from 
        cash_receipt cr inner join invoice inv on inv.id = cr.invoice_id
        left outer join payment_method method on method.id = cr.payment_method_id;
