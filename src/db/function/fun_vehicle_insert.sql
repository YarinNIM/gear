select * from fun_dropfunction('fun_vehicle_insert');
create or replace function fun_vehicle_insert(
    p_aid integer, p_v jsonb) returns integer as $$
declare
    p_tmp integer;
begin
    select id into p_tmp
    from vehicle
    where plate_number = p_v->>'plate_number'
        and province_id = (p_v->>'province_id')::integer
        and plate_number is not null;

    if found then
        raise exception 'Plate number exists';
    end if;

    insert into vehicle(vehicle_model_id, plate_number, year, color_id, province_id, description, account_id)
    values(
        (p_v->>'model_id')::integer,
        p_v->>'plate_number',
        p_v->>'year',
        (p_v->>'color_id')::integer,
        (p_v->>'province_id')::integer,
        p_v->>'description',
        p_aid
    );

    return currval('vehicle_id_seq');

end $$ language plpgsql;
