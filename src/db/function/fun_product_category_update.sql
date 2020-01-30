select * from fun_dropfunction('fun_product_category_update');
create or replace function fun_product_category_update(
    p_id integer,
    p_cat jsonb) returns integer as $$
declare
    p_tmp integer;
begin
    select id into p_tmp
    from product_category
    where (lower(name_en) = lower(p_cat->>'name_en')
        or lower(icon) = lower(p_cat->>'icon')) 
        and p_id != id;

    if found then
        raise exception 'Name or Icon already exists';
    end if;

    update product_category
    set
        category_key = p_cat->>'category_key',
        name_en = p_cat->>'name_en',
        name_kh = p_cat->>'name_kh',
        icon = p_cat->>'icon',
        range = (p_cat->>'range')::integer,
        description = p_cat->>'description'
    where id = p_id;

    return p_id;


end $$ language plpgsql;
