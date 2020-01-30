drop view view_invoice_cash_receipt cascade;
create view view_invoice_cash_receipt as

select invoice_id,
    sum(amount)::decimal(8,4) as amount
from cash_receipt
where status = true
group by invoice_id;
