select * from fun_dropfunction('fun_vehicle_type_insert');
create or replace function fun_vehicle_type_insert ( p_type jsonb) returns integer as $$
declare
    p_tmp integer;
begin

    select id into p_tmp
    from vehicle_type
    where lower(name_en) = lower(p_type->>'name_en');

    if found then
        raise exception 'Vehicle type name already exists';
    end if;

    insert into vehicle_type(name_en, name_kh, icon, description)
    values(
        p_type->>'name_en',
        p_type->>'name_kh',
        p_type->>'icon',
        p_type->>'description'
    );

    p_tmp := currval('vehicle_type_id_seq');

    if (p_type->>'parent_id')::integer > 0 then
        update vehicle_type
        set parent_id = (p_type->>'parent_id')::integer
        where id = p_tmp;
    end if;

    return p_tmp;

end $$ language plpgsql;
