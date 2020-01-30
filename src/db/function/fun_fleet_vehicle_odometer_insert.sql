select * from fun_dropfunction('fun_fleet_vehicle_odometer_insert');
create or replace function fun_fleet_vehicle_odometer_insert(
    p_vid integer,
    p_odometer integer,
    p_cid integer, -- account perform entry
    p_aid integer -- which garage served
) returns integer as $$
declare
begin

    insert into vehicle_odometer(
        vehicle_id, 
        odometer,
        account_id,
        company_id) 
    values(
        p_vid,
        p_odometer,
        p_aid,
        p_cid
    );

    return currval('vehicle_odometer_id_sep');

end $$ language plpgsql;
