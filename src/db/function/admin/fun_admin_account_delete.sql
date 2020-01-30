select * from fun_dropfunction('fun_admin_account_delete');
create or replace function fun_admin_account_delete(
    p_ac_id integer,
    p_aid integer
) returns integer as $$
declare
begin 

    perform fun_admin_validate_permission(p_aid, 'admin_account.delete');

    update account
    set is_super_user = false,
        admin_role_id = null
    where id = p_ac_id;

    return 1;

end $$ language plpgsql;
