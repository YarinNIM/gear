select * from fun_dropfunction('fun_vehicle_update');
create or replace function fun_vehicle_update(
    p_id integer, p_v jsonb) returns integer as $$
declare
    p_tmp integer;
begin
    select id into p_tmp
    from vehicle
    where plate_number = p_v->>'plate_number'
        and plate_number is not null
        and province_id = (p_v->>'province_id')::integer
        and id != p_id;

    if found then
        raise exception 'Plate number exists';
    end if;

    update vehicle 
    set
        vehicle_model_id = (p_v->>'model_id')::integer,
        plate_number = p_v->>'plate_number',
        year = p_v->>'year',
        color_id = (p_v->>'color_id')::integer,
        province_id = (p_v->>'province_id')::integer,
        description = p_v->>'description'
    where id = p_id;

    return p_id;

end $$ language plpgsql;
