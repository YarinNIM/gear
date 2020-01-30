select * from fun_dropfunction('fun_product_model_update');
create or replace function fun_product_model_update(
    p_id integer, p_model jsonb) returns integer as $$
declare
    p_tmp integer;
begin

    select id into p_tmp
    from product_model
    where lower(name) = lower(p_model->>'name')
        and lower(code) = lower(p_model->>'code')
        and category_id = (p_model->>'category_id')::integer
        and brand_id = (p_model->>'brand_id')::integer
        and id !=  p_id;

    if found then
        raise exception 'Model already exists';
    end if;

    update product_model
    set 
        name = p_model->>'name',
        code = p_model->>'code',
        brand_id = (p_model->>'brand_id')::integer
    where  id = p_id;

    return p_id;

end $$ language plpgsql;
