select * from fun_dropfunction('fun_cash_receipt_insert');
create or replace function fun_cash_receipt_insert(
    p_inv_id integer,
    p_amount decimal,
    p_detail jsonb,
    p_aid integer
) returns integer as $$
declare
begin
    insert into cash_receipt(
        invoice_id, amount, 
        ref_no, description, received_by,
        account_id)
    values(
        p_inv_id, p_amount,
        p_detail->>'ref_no',p_detail->>'description', p_detail->>'received_by',
        p_aid);

    return currval('cash_receipt_id_seq');

end $$ language plpgsql;
