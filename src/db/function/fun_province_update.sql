select * from fun_dropfunction('fun_province_update');
create or replace function fun_province_update( p_id integer, p_prov jsonb) returns integer as $$
declare
    p_tmp integer;
begin

    select id into p_tmp
    from province
    where (lower(name_en) = lower(p_prov->>'name_en')
        or lower(name_kh) = lower(p_prov->>'name_kh'))
        and id != p_id and country_id = (p_prov->>'country_id')::integer;

    if found then
        raise exception 'Name already exists';
    end if;

    update province
    set name_en = p_prov->>'name_en',
        name_kh = p_prov->>'name_kh',
        status = (p_prov->>'status')::boolean,
        is_delivery_destination = (p_prov->>'is_delivery_destination')::boolean
    where id = p_id;

    return p_id;

end $$ language plpgsql;
