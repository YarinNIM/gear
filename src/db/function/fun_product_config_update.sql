select * from fun_dropfunction('fun_product_config_update');
create or replace function fun_product_config_update(
    p_id integer, p_conf jsonb) returns integer as $$
declare
    p_tmp integer;
begin

    update product 
    set 
        status = (p_conf->>'status')::boolean,
        sold_out = (p_conf->>'sold_out')::boolean,
        
        cost = (p_conf->>'cost')::decimal,
        old_price = (p_conf->>'old_price')::decimal,
        selling_price = (p_conf->>'selling_price')::decimal,
        min_order = (p_conf->>'min_order')::integer,
        unit_type_id = (p_conf->>'unit_type_id')::integer
    where id = p_id;

    return p_id;


end $$ language plpgsql;
