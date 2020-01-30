select * from fun_dropfunction('fun_product_model_insert');
create or replace function fun_product_model_insert(
    p_model jsonb, p_aid integer) returns integer as $$
declare
    p_tmp integer;
begin

    select id into p_tmp
    from product_model
    where lower(name) = lower(p_model->>'name')
        and lower(code) = lower(p_model->>'code')
        and category_id = (p_model->>'category_id')::integer
        and brand_id = (p_model->>'brand_id')::integer;

    if found then
        raise exception 'Model name already exists';
    end if;

    insert into product_model (name, code, category_id, brand_id, account_id)
    values(
        p_model->>'name',
        p_model->>'code',
        (p_model->>'category_id')::integer,
        (p_model->>'brand_id')::integer,
        p_aid
    );

    return currval('product_model_id_seq');

end $$ language plpgsql;
