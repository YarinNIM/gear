select * from fun_dropfunction('fun_account_login');

CREATE OR REPLACE FUNCTION fun_account_login(
    p_email varchar, 
    p_pwd varchar) RETURNS integer AS $$
declare 
    p_tmp integer;
BEGIN

    select account.id into p_tmp
    from account inner join email on account.email_id = email.id
    where lower(email.email) = lower(p_email)
        and account.verified = false;

    if found then
        raise exception 'account_not_verified';
    end if;

    raise exception '%', p_email;

    select account.id into p_tmp
    from account left outer join email on account.email_id = email.id
        left outer join phone on account.phone_id = phone.id
    where account.password = p_pwd and(
        phone.phone = lower(p_email) or
        lower(email.email) = lower(p_email)) and
        account.status = true
        and account.verified = true;

    if not found then
        raise exception 'Invalid account credential';
    end if;

    return p_tmp;
    
END $$ language plpgsql;
