select * from fun_dropfunction('fun_invoice_detail_insert');
create or replace function fun_invoice_detail_insert(
    p_inv_id integer,
    p_parent_id integer,
    p_products jsonb[],
    p_inv_type varchar
) returns integer as $$
declare
    p_product jsonb;
    p_tmp jsonb;
    p_price decimal;
    p_vat smallint;
begin

    select value::smallint into p_vat
    from configure where key = 'VAT' limit 1;

    foreach p_product in array p_products
    loop

        p_product = coalesce(p_product->0, p_product);

        p_price = (p_product->>'selling_price')::decimal;
        if p_inv_type = 'COM_INVOICE' then
            p_price = p_price + (p_price * p_vat * 0.01);
        end if;


        insert into invoice_detail(
            invoice_id, attached_to, 
            product_id, unit_price, qty, discount)
        values(
            p_inv_id, p_parent_id,
            (p_product->>'id')::integer,
            p_price,
            (p_product->>'qty')::smallint,
            (p_product->>'discount')::smallint
        );
    end loop;

    return p_parent_id;

end $$ language plpgsql;
