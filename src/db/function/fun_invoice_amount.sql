select * from fun_dropfunction('fun_invoice_amount');
create or replace function fun_invoice_amount(
    p_amount decimal,
    p_discount smallint,
    p_vat smallint
) returns decimal(6,4) as $$
declare 
    p_total decimal;
begin
    p_total := p_amount - (p_amount * p_discount * 0.01);
    p_total := p_total + (p_total * p_vat * 0.01);
    return p_total;

end $$ language plpgsql;
