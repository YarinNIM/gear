select * from fun_dropfunction('fun_fleet_factory_service');
create or replace function fun_fleet_factory_service(
    p_cid integer
) returns integer as $$
declare 
    p_srv_id integer;
begin

    select id into p_srv_id
    from service 
    where service_key = 'FLEET';

    raise notice 'Service Fleet: %', p_srv_id;

    insert into service_product(company_id, service_id, product_id)
    select p_cid, p_srv_id, product.id
    from product
    where company_id is null
        and service_id = p_srv_id
        and id not in (
            select product_id
            from service_product
            where company_id = p_cid and service_id = p_srv_id
        );
    return 1;
end $$ language plpgsql;
