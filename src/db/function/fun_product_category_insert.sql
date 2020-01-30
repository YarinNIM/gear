select * from fun_dropfunction('fun_product_category_insert');
create or replace function fun_product_category_insert(
    p_cat jsonb, p_aid integer) returns integer as $$
declare
    p_tmp integer;
    p_pid integer;
begin
    select id into p_tmp
    from product_category
    where lower(name_en) = lower(p_cat->>'name_en')
        or lower(icon) = lower(p_cat->>'icon');

    if found then
        raise exception 'Name or Icon already exists';
    end if;

    p_pid = (p_cat->>'parent_id')::integer;

    insert into product_category(
        name_en, name_kh, icon, category_key,
        range, description, account_id)
    values(
        p_cat->>'name_en',
        p_cat->>'name_kh',
        p_cat->>'icon',
        p_cat->>'category_key',
        (p_cat->>'range')::integer,
        p_cat->>'description',
        p_aid
    );

    p_tmp = currval('product_category_id_seq');

    if p_pid > 0 then
        update product_category
        set parent_id = p_pid
        where id = p_tmp;
    end if;

    return p_tmp;

end $$ language plpgsql;
