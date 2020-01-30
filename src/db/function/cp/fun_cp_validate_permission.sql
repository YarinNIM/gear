select * from fun_dropfunction('fun_cp_validate_permission');
create or replace function fun_cp_validate_permission(
    p_cid integer,
    p_aid integer,
    p_perm varchar
) returns boolean as $$

declare
    p_bol boolean;
    p_str jsonb;
begin

    p_str = '{"' || p_perm || '": true}';

    select ca.status into p_bol
    from  company_account ca inner join role_permission role on ca.role_id = role.id
    where ca.account_id = p_aid
        and ca.status = true 
        and ca.company_id = p_cid
        and role.status = true
        and role.permissions @> p_str;

    if p_bol = true then
        return true;
    end if;
    
    raise exception 'Invalid permission';

end $$ language plpgsql;
