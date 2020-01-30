select * from fun_dropfunction('fun_district_update');
create or replace function fun_district_update(
    p_id integer, p_dist jsonb ) returns integer as $$
declare
    p_tmp integer; -- temporary district id
begin
    select id into p_tmp
    from district
    where (lower(name_en) = lower(p_dist->>'name_en')
        or lower(name_kh) = lower(p_dist->>'name_kh'))
        and id != (p_dist->>'id')::integer
        and province_id = (p_dist->>'province_id')::integer;

    if found then
        raise exception 'District name already exists';
    end if;

    update district
    set name_en = p_dist->>'name_en',
        name_kh = p_dist->>'name_kh',
        status = (p_dist->>'status')::boolean,
        is_delivery_destination = (p_dist->>'is_delivery_destination')::boolean
    where id = p_id;

    return p_id;
end $$ language plpgsql;
