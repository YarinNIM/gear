select * from fun_dropfunction('fun_admin_role_permission_insert');
create or replace function fun_admin_role_permission_insert(
    p_data jsonb,
    p_aid integer,
    p_perm varchar
) returns integer as $$
declare
    p_rid integer;
    p_status boolean;
    p_admin boolean;
    p_perms jsonb;
begin

    perform fun_admin_validate_permission(p_aid, p_perm);
    p_admin = p_data->'is_admin_role';

    select id into p_rid
    from role_permission
    where lower(name) = lower(p_data->>'name') 
    and is_admin_role = p_admin;

    if found then
        raise exception 'Name already exists';
    end if;

    p_status = p_data->'status';
    p_perms = p_data->>'permissions';

    insert into role_permission(name, status, permissions, is_admin_role, created_by)
    values(
        p_data ->>'name',
        p_status,
        p_perms,
        p_admin,
        p_aid
    );

    return currval('role_permission_id_seq');

end $$ language plpgsql;
