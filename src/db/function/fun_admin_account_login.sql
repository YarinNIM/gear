select * from fun_dropfunction('fun_admin_account_login');
CREATE FUNCTION public.fun_admin_account_login(
    p_email character varying, 
    p_pwd character varying) RETURNS integer LANGUAGE plpgsql AS $$
declare 
    p_aid integer;
BEGIN
    p_aid = fun_account_login(p_email, p_pwd);

    select account.id into p_aid
    from account inner join email on account.email_id = email.id
        left outer join role_permission role on account.admin_role_id = role.id
    where account.status = true and account.verified = true
        and (account.is_super_user = true or account.admin_role_id is not null)
        and account.password = p_pwd and lower(email.email) = lower(p_email);

    if not found then
        raise exception 'Invalid admin account email/password';
    end if;

    return p_aid;

END $$;

