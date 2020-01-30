select * from fun_dropfunction('fun_delivery_order_insert');
create or replace function fun_delivery_order_insert(
    p_delivery jsonb, p_items jsonb[],
    p_del_addr_id integer, 
    p_cid integer, p_aid integer
) returns integer as $$
declare
    p_oid integer;
    p_item jsonb;
begin 

    insert into delivery_order(
        tax, contact_number, delivery_address_id,
        delivery_date, delivery_charge, description, 
        is_asap, company_id, account_id)
    values(
        0, p_delivery->>'contact_number', p_del_addr_id,
        (p_delivery->>'delivery_date')::timestamp, (p_delivery->>'delivery_charge')::decimal,
        p_delivery->>'description', (p_delivery->>'is_asap')::bool,
        p_cid, p_aid
    );

    p_oid = currval('delivery_order_id_seq');

    foreach p_item in array p_items
    loop
        insert into delivery_order_detail(
            delivery_order_id, product_id, qty, 
            unit_price, description) 
        values(
            p_oid, (p_item->>'product_id')::integer, (p_item->>'qty')::integer,
            (p_item->>'selling_price')::decimal,p_item->>'description' 
        );
    end loop;

    return p_oid;


end $$ language plpgsql;
