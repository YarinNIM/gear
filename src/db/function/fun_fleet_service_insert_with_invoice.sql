select * from fun_dropfunction('fun_fleet_service_insert_with_invoice');
create or replace function fun_fleet_service_insert_with_invoice(
    p_vehicle jsonb,
    p_inv jsonb,
    p_services jsonb[],
    p_products jsonb[],

    p_customer jsonb,
    p_cid integer,
    p_aid integer
) returns integer as $$
declare
    p_inv_id integer; -- invoice id from created invoice
    p_sid integer; -- fleet service id will be returned
begin

    p_inv_id := fun_invoice_insert(p_inv, p_services, p_products, p_customer, p_cid, p_aid);
    p_sid = fun_fleet_service_insert(
        p_inv_id,
        (p_vehicle->>'id')::integer,
        (p_vehicle->>'odometer')::integer,
        p_inv->>'description',
        p_services, p_products
    );
    return p_sid;

end $$ language plpgsql;
