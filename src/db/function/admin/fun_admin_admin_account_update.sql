select * from fun_dropfunction('fun_admin_account_update');
create or replace function fun_admin_account_update(
    p_ac_id integer,
    p_rid integer,
    p_aid integer
)returns integer as $$
declare
begin

    perform fun_admin_validate_permission(p_aid, 'admin_account.update');
    update account
    set admin_role_id = p_rid
    where id = p_ac_id;

    return 1;

end $$ language plpgsql;

