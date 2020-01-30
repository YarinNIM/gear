-- For inserting cash receipt seperatly from invoice. 
-- Not at the time inserting invoice
select * from fun_dropfunction('fun_cash_receipt_insert_sep');
create or replace function fun_cash_receipt_insert_sep(
    p_inv_id integer,
    p_amount decimal(6,4),
    p_cr jsonb,
    p_cid integer,
    p_aid integer
) returns integer as $$
declare
    p_int integer;
    p_inv_amount decimal(6,4);
    p_cr_amount decimal(6,4);
    p_remain_amount decimal(6,4);
begin
    select id into p_int
    from invoice
    where id = p_inv_id and company_id = p_cid;

    if not found then
        raise exception 'Invoice number not exist';
    end if;
    

    select id into p_int
    from view_cash_receipt
    where 
        ref_no = p_cr->>'ref_no' 
        and company_id = p_cid;

    if found then
        raise exception 'Duplicate Ref. Number';
    end if;

    select total into p_inv_amount
    from view_invoice
    where id = p_inv_id limit 1;

    select amount into p_cr_amount
    from view_invoice_cash_receipt
    where invoice_id = p_inv_id limit 1;

    if not found then
        p_cr_amount := 0;
    end if;

    p_remain_amount := p_inv_amount - p_cr_amount;

    if p_remain_amount <= 0 then
        raise exception 'This invoice already paid, try another Invoice.';
    end if;

    if p_remain_amount < p_amount then
        raise exception 'Amount is bigger than remain amount';
    end if;


    insert into cash_receipt(
        invoice_id, ref_no, amount, 
        description, received_date, received_from, received_by,
        payment_method_id, account_id)
    values(
        p_inv_id, p_cr->>'ref_no', p_amount,
        p_cr->>'description', (p_cr->>'received_date')::timestamp,
        p_cr->>'received_from', p_cr->>'received_by',
        (p_cr->>'payment_method_id')::smallint,
        p_aid);

    return currval('cash_receipt_id_seq');

        


end $$ language plpgsql;
