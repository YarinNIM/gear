select * from fun_dropfunction('fun_admin_account_update');
create or replace function fun_admin_account_update(
    p_ac_id integer, p_rid integer
)returns integer as $$
declare
begin

    update account
    set admin_role_id = p_rid
    where id = p_ac_id;

    return 1;

end $$ language plpgsql;

