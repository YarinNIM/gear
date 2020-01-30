select * from fun_dropfunction('fun_product_brand_update');
create or replace function fun_product_brand_update(
    p_id integer, p_brand jsonb) returns integer as $$
declare 
    p_tmp integer;
begin

    select id into p_tmp
    from product_brand
    where lower(p_brand->>'name') = lower(name)
    and id != p_id;

    if found then 
        raise exception 'Name already exists';
    end if;

    update product_brand
    set name = p_brand->>'name',
        company_name = p_brand->>'company_name',

        is_automotive = (p_brand->>'is_automotive')::boolean,
        is_cosmetic = (p_brand->>'is_cosmetic')::boolean,
        is_electronic = (p_brand->>'is_electronic')::boolean,
        is_food = (p_brand->>'is_food')::boolean,
        is_vehicle = (p_brand->>'is_vehicle')::boolean,
        is_wear = (p_brand->>'is_wear')::boolean
    where id = p_id;

    return p_id;

end $$ language plpgsql;
