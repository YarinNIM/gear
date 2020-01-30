select * from fun_dropfunction('fun_admin_company_address_update');
create or replace function fun_admin_company_address_update(
    p_addr jsonb,
    p_cid integer,
    p_aid integer,
    p_perm varchar )returns integer as $$
declare
    p_mo boolean;
    p_province_id integer;
    p_id integer;
begin
    perform fun_admin_validate_permission(p_aid, p_perm);

    p_mo = p_addr->'is_main_office';
    p_province_id = p_addr->'province_id';
    p_id = p_addr->'id';

    update company_address
    set line_a =  p_addr->>'line_a',
        line_b = p_addr->>'line_b',
        location = p_addr->>'location',
        province_id  = p_province_id,
        is_main_office = p_mo

    where  company_id = p_cid and id = p_id;

    return p_id;

end $$ language plpgsql;
