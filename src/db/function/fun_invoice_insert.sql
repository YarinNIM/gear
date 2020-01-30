select * from fun_dropfunction('fun_invoice_insert');
create or replace function fun_invoice_insert(
    p_inv jsonb,
    p_services jsonb[],
    p_products jsonb[],

    p_customer jsonb,
    p_cid integer,
    p_aid integer
) returns integer as $$
declare
    p_service jsonb;
    p_srv_products jsonb[];
    p_product jsonb;
    p_srv_id integer; -- The invoice which service is for
    p_inv_id integer;
    p_parent_id integer;

    p_cr jsonb;
    p_unit_price decimal;

    p_vat smallint;
    p_tmp jsonb;
begin

    select id into p_srv_id
    from service where service_key = p_inv->>'service_key';

    select value::smallint into p_vat
    from configure
    where key = 'VAT' limit 1;

    insert into invoice(
        company_id, account_id,
        service_id, invoice_type, description, discount,
        customer_id, customer_company_id, vat)
    values(
        p_cid, p_aid,
        p_srv_id, p_inv->>'invoice_type',p_inv->>'description', (p_inv->>'discount')::smallint,
        (p_customer->>'account_id')::integer,(p_customer->>'company_id')::integer,
        case p_inv->>'invoice_type'
        when 'TAX_INVOICE' then p_vat
        else 0
        end
    );

    p_inv_id := currval('invoice_id_seq');

    FOREACH p_service IN ARRAY p_services
    LOOP

        p_unit_price = (p_service->>'selling_price')::decimal;
        if p_inv->>'invoice_type' = 'COM_INVOICE' then
            p_unit_price = p_unit_price + p_unit_price * p_vat * 0.01;
        end if;

        insert into invoice_detail(
            invoice_id, product_id, 
            unit_price, qty, discount)
        values(
            p_inv_id,
            (p_service->>'id')::integer,
            p_unit_price,
            (p_service->>'qty')::smallint,
            (p_service->>'discount')::smallint
        );

        p_parent_id := currval('invoice_detail_id_seq');
        p_srv_products := array(select jsonb_array_elements(p_service->'products'));
        perform fun_invoice_detail_insert(
            p_inv_id, 
            p_parent_id, 
            p_srv_products, 
            p_inv->>'invoice_type'
        );

    END LOOP;

    --- insert products in services
    perform fun_invoice_detail_insert(
        p_inv_id, 
        null, 
        p_products,
        p_inv->>'invoice_type'
    );
    
    -- Add cash receipt

    if (p_inv->>'is_paid')::boolean = true then
        p_cr = '{"description": "Paid invoice"}';
        perform fun_cash_receipt_insert(
            p_inv_id, 
            (p_inv->>'amount')::decimal,
            p_cr,
            p_aid
        );
    end if;

    return p_inv_id;
end $$ language plpgsql;
