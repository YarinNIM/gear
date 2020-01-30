select * from fun_dropfunction('fun_fleet_service_insert');
create or replace function fun_fleet_service_insert(
    p_inv_id integer,
    p_vid integer,
    p_odometer integer,
    p_desc varchar,
    p_services jsonb[],
    p_products jsonb[]
) returns integer as $$
declare
    p_service jsonb;
    p_srv_products jsonb[];
    p_sid integer;
    p_p_sid integer;
begin

    insert into fleet_service( invoice_id, vehicle_id, vehicle_odometer, description)
    values( p_inv_id, p_vid, p_odometer, p_desc);

    p_sid := currval('fleet_service_id_seq');


    FOREACH p_service IN ARRAY p_services
    LOOP
        insert into fleet_service_detail(
            fleet_service_id, 
            product_id, qty, km_to_use)
        values(
            p_sid,
            (p_service->>'id')::integer,
            (p_service->>'qty')::smallint,
            (p_service->>'km')::smallint);

        p_p_sid := currval('fleet_service_detail_id_seq');

        --p_srv_products = ARRAY[p_service->>'products'];
        p_srv_products := array(select jsonb_array_elements(p_service->'products'));
        perform fun_fleet_service_detail_insert(
            p_sid, p_p_sid, p_srv_products
        );

    END LOOP;

    perform fun_fleet_service_detail_insert( p_sid, null, p_products);

    return p_sid;


end $$ language plpgsql;
