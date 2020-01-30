select * from fun_dropfunction('fun_admin_account_insert');
create or replace function fun_admin_account_insert(
    p_email varchar, 
    p_role_id integer
) returns integer as $$
declare 
    p_acid integer;
    p_rid integer;
begin

    select account.id into p_acid
    from account inner join email on account.email_id = email.id
    where lower(email.email) = lower(p_email);

    if not found then 
        raise exception 'Email not exist';
    end if;

    select admin_role_id into p_rid
    from account
    where id = p_acid and (is_super_user = true or admin_role_id is not null);

    if found then 
        raise exception 'Account already in admin';
    end if;

    update account 
    set admin_role_id = p_role_id
    where id = p_acid;

    return p_acid;

end $$ language plpgsql;
