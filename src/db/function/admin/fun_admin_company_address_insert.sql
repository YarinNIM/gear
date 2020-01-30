select * from fun_dropfunction('fun_admin_company_address_insert');
create or replace function fun_admin_company_address_insert(
    p_addr jsonb,
    p_cid integer,
    p_aid integer
) returns integer as $$
declare
    p_mo boolean;
    p_province_id integer;
begin

    p_mo = p_addr->'is_main_office';
    p_province_id = p_addr->'province_id';

    perform fun_admin_validate_permission(p_aid, 'company.modify');
    insert into company_address(line_a, line_b, location, is_main_office, company_id, account_id, province_id)
    values(p_addr->>'line_a', p_addr->>'line_b', p_addr->>'location', p_mo, p_cid, p_aid, p_province_id);

    return currval('company_address_id_seq');

end $$ language plpgsql;
