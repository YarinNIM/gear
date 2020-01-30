select * from fun_dropfunction('fun_vehicle_model_update');
create or replace function fun_vehicle_model_update(
    p_id integer, p_model jsonb) returns integer as $$
declare
    p_tmp integer;
begin

    select id into p_tmp
    from vehicle_model
    where 
        lower(model_number) = lower(p_model->>'model_number')
        and brand_id = (p_model->>'brand_id')::integer
        -- and vehicle_type_id = (p_model->>'vehicle_type_id')::integer
        and id != p_id;

    if found then
        raise exception 'This model already exists';
    end if;

    update vehicle_model
    set brand_id = (p_model->>'brand_id')::integer,
        vehicle_type_id = (p_model->>'vehicle_type_id')::integer,
        model_number = p_model->>'model_number',
        model_name = p_model->>'model_name'
    where id = p_id;

    return p_id;

end $$ language plpgsql;
