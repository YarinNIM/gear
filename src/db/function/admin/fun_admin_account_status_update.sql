select * from fun_dropfunction('fun_admin_account_status_update');
create or replace function fun_admin_account_status_update(
    p_status boolean,
    p_id integer,
    p_aid integer,
    p_perm varchar
) returns integer as $$
begin

    perform fun_admin_validate_permission(p_aid, p_perm);

    update account
    set status = p_status
    where id = p_id;

    return p_id;

end $$ language plpgsql;
