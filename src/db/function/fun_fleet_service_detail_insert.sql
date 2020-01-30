select * from fun_dropfunction('fun_fleet_service_detail_insert');
create or replace function fun_fleet_service_detail_insert(
    p_sid integer,
    p_p_sid integer,
    p_products jsonb[]
) returns integer as $$
declare
    p_product jsonb;
begin

    foreach p_product in array p_products
    loop
        p_product = coalesce(p_product->0, p_product);
        
        insert into fleet_service_detail(
            fleet_service_id, attached_to,
            product_id, qty)
        values(
            p_sid, p_p_sid,
            (p_product->>'id')::integer,
            (p_product->>'qty')::smallint);
    end loop;

    return p_p_sid;

end $$ language plpgsql;
