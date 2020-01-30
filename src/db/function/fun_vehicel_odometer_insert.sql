select * from fun_dropfunction('fun_vehicle_odometer_insert');
create or replace function fun_vehicle_odometer_insert(
    p_vid integer,
    p_meter integer,
    p_aid integer
) returns integer as $$
begin
end $$ language plpgsql;
