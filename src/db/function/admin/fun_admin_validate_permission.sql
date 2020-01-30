select * from fun_dropfunction('fun_admin_validate_permission');
create or replace function fun_admin_validate_permission(
    p_aid integer,
    p_perm varchar
) returns boolean as $$

declare
    p_bol boolean;
    p_str jsonb;
begin

    p_str = '{"' || p_perm || '": true}';

    select account.is_super_user into p_bol
    from account where id = p_aid and status = true
    and verified = true;

    if p_bol = true then
        return true;
    end if;

    select account.status into p_bol
    from account inner join role_permission role on account.admin_role_id = role.id
    where 
        account.id = p_aid and account.status = true and account.verified = true
        and role.is_admin_role = true
        and role.permissions @> p_str;

    if p_bol = true then
        return true;
    end if;
    
    raise exception 'Invalid permission';

end $$ language plpgsql;
