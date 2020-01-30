select * from fun_dropfunction('fun_cp_company_address_update');
create or replace function fun_cp_company_address_update(
    p_addr jsonb, p_cid integer, p_aid integer, p_perm varchar) returns integer as $$
declare
    p_addr_id integer;
begin
    perform fun_cp_validate_permission(p_cid, p_aid, p_perm);
    p_addr_id  = fun_company_address_update(p_cid, (p_addr->>'id')::integer, p_addr);
    return p_addr_id;
    
end $$ language plpgsql;
