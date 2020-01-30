select * from fun_dropfunction('fun_admin_role_permission_delete');
create or replace function fun_admin_role_permission_delete(
    p_id integer,
    p_aid integer,
    p_perm varchar
) returns integer as $$
begin
    perform fun_admin_validate_permission(p_aid, p_perm);
    delete from role_permission where id = p_id;
    return p_id;
end $$ language plpgsql;
