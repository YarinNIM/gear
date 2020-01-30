select * from fun_dropfunction('fun_vehicle_type_update');
create or replace function fun_vehicle_type_update(
    p_id integer, p_type jsonb) returns integer as $$
declare
    p_tmp integer;
begin

    select id into p_tmp
    from vehicle_type
    where lower(name_en) = lower(p_type->>'name_en')
        and id != p_id;

    if found then 
        raise exception 'Vehicle type already exists';
    end if;

    update vehicle_type
    set name_en = p_type->>'name_en',
        name_kh = p_type->>'name_kh',
        icon = p_type->>'icon',
        description = p_type->>'description'
    where id = p_id;

    return p_id;

end $$ language plpgsql;
