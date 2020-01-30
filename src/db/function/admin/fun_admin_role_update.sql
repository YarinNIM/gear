select * from fun_dropfunction('fun_admin_role_permission_update');
create or replace function fun_admin_role_permission_update(
    p_data jsonb,
    p_aid integer,
    p_perm varchar
) returns integer as $$
declare
    p_id integer;
    p_is_admin boolean;
    p_perms jsonb;
    p_status boolean;
    p_tmp integer;
    p_name varchar;
begin
    perform fun_admin_validate_permission(p_aid, p_perm);

    p_is_admin = p_data->'is_admin_role';
    p_id = p_data->'id';
    p_name = p_data->>'name';

    select id into p_tmp
    from role_permission
    where lower(name) = lower(p_name)
        and is_admin_role = p_is_admin
        and id <> p_id;

    if found then
        raise exception 'Name already exists';
    end if;

    p_perms = p_data->'permissions';
    p_status = p_data->'status';

    update role_permission
    set name = p_name,
        permissions = p_perms,
        status = p_status,
        is_admin_role = p_is_admin
    where id = p_id;

    return p_id;

end $$ language plpgsql;
