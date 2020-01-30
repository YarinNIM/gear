select * from fun_dropfunction('fun_admin_company_sub_company_insert');
create or replace function fun_admin_company_sub_company_insert(
    p_cid integer,
    p_sid integer,
    p_aid integer,
    p_perm varchar
) returns integer as $$
begin
    perform fun_admin_validate_permission(p_aid, p_perm);

    update company
    set parent_company_id = p_cid
    where id = p_sid and parent_company_id is null;
    
    return p_sid;
end $$ language plpgsql;
