select * from fun_dropfunction('fun_company_address_insert');
create or replace function fun_company_address_insert(
    p_cid integer,
    p_addr jsonb,
    p_aid integer
) returns integer as $$
begin

    insert into company_address(line_a, line_b, location, is_main_office, company_id, account_id, province_id)
    values(
        p_addr->>'line_a', 
        p_addr->>'line_b', 
        p_addr->>'location', 
        (p_addr->>'is_main_office')::boolean,
        p_cid,
        p_aid, 
        (p_addr->>'province_id')::integer
    );

    return currval('company_address_id_seq');

end $$ language plpgsql;
