select * from fun_dropfunction('fun_district_insert');
create or replace function fun_district_insert( p_dist jsonb) returns integer as $$
declare
    p_id integer; -- district id
    p_pic integer; -- province id
begin

    p_pic := (p_dist->>'province_id')::integer;

    select id into p_id
    from district 
    where lower(name_en) = lower(p_dist->>'name_en')
        or lower(name_kh) = lower(p_dist->>'name_kh');

    if found then
        raise exception 'District name already exists';
    end if;

    insert into district(
        province_id, name_en, name_kh, 
        status, is_delivery_destination)
    values(p_pic, p_dist->>'name_en', p_dist->>'name_kh', 
        (p_dist->>'status')::boolean,
        (p_dist->>'is_delivery_destination')::boolean
    );

    return currval('district_id_seq');

end $$ language plpgsql;
