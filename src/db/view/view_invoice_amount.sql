drop view view_invoice_amount cascade;
create view view_invoice_amount as 
select 
    invoice_id,
    sum((unit_price -( unit_price * discount * 0.01)) * qty)::decimal(8,4) as amount
    --sum((unit_price * qty) - (unit_price * qty * discount / 100)) as amount
from invoice_detail
group by invoice_id;
