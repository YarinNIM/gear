select * from fun_dropfunction('fun_vehicle_model_insert');
create or replace function fun_vehicle_model_insert(
    p_aid integer, p_model jsonb) returns integer as $$
declare
    p_tmp integer;
begin

    select id into p_tmp
    from vehicle_model
    where 
        lower(model_number) = lower(p_model->>'model_number')
        and brand_id = (p_model->>'brand_id')::integer;
        --and vehicle_type_id = (p_model->>'vehicle_type_id')::integer;

    if found then
        raise exception 'This model already exists';
    end if;

    insert into vehicle_model(brand_id, vehicle_type_id, model_number, model_name, account_id)
    values(
        (p_model->>'brand_id')::integer,
        (p_model->>'vehicle_type_id')::integer,
        p_model->>'model_number',
        p_model->>'model_name',
        p_aid
    );

    return currval('vehicle_model_id_seq');


end $$ language plpgsql;
