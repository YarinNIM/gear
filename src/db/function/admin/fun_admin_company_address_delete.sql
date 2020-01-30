select * from fun_dropfunction('fun_admin_company_address_delete');
create or replace function fun_admin_company_address_delete(
    p_cid integer,
    p_addr_id integer,
    p_aid integer,
    p_perm varchar
) returns integer as $$
begin
    perform fun_admin_validate_permission(p_aid, p_perm);
    update company_address
    set status = false
    where company_id = p_cid and id = p_addr_id;

    return p_addr_id;
end $$ language plpgsql;
