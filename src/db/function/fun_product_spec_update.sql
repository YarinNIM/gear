select * from fun_dropfunction('fun_product_spec_update');
create or replace function fun_product_spec_update(
    p_id integer, p_spec jsonb) returns integer as $$
declare
    p_tmp integer;
begin

    select id into p_tmp
    from product_specification
    where (lower(name_en) = lower(p_spec->>'name_en')
        or lower(name_kh) = lower(p_spec->>'name_kh'))
        and id != p_id;


    if found then
        raise exception 'Name already exists';
    end if;

    update product_specification
    set 
        name_en =  p_spec->>'name_en',
        name_kh = p_spec->>'name_kh',
        description = p_spec->>'description'
    where id = p_id;

    return p_id;

end $$ language plpgsql;
