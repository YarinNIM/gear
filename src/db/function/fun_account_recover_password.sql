select * from fun_dropfunction('fun_account_recover_password');
create or replace function fun_account_recover_password(
    p_email varchar) returns integer as $$
declare
    p_tmp integer;
begin

    select account.id into p_tmp
    from account inner join email on  account.email_id = email.id
    where lower(email.email) = lower(p_email)
        and account.verified = false;

    if found then
        raise exception 'account_not_verified';
    end if;

    select account.id into p_tmp
    from account inner join email on email.id = account.email_id
    where lower(email.email) = lower(p_email)
        and account.verified = true;

    if not found then
        raise exception 'No account associated with this email';
    end if;

    return p_tmp;

        
end $$ language plpgsql;
