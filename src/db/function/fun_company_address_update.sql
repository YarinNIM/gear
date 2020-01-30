select * from fun_dropfunction('fun_company_address_update');
create or replace function fun_company_address_update(
    p_id integer,
    p_addr jsonb)returns integer as $$
begin

    update company_address
    set line_a =  p_addr->>'line_a',
        line_b = p_addr->>'line_b',
        location = p_addr->>'location',
        province_id  = (p_addr->>'province_id')::integer,
        is_main_office = (p_addr->>'is_main_office')::boolean
    where id = p_id;

    return p_id;

end $$ language plpgsql;
