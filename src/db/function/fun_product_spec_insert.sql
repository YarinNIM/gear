select * from fun_dropfunction('fun_product_spec_insert');
create or replace function fun_product_spec_insert(
    p_spec jsonb, p_aid integer) returns integer as $$
declare
    p_tmp integer;
begin

    select id into p_tmp
    from product_specification
    where lower(name_en) = lower(p_spec->>'name_en')
        or lower(name_kh) = lower(p_spec->>'name_kh');

    if found then
        raise exception 'Name already exists';
    end if;

    insert into product_specification(name_en, name_kh, description, account_id)
    values(p_spec->>'name_en', p_spec->>'name_kh', p_spec->>'description', p_aid);

    return currval('product_specification_id_seq');

end $$ language plpgsql;
