select * from fun_dropfunction('fun_account_verify');
CREATE OR REPLACE FUNCTION fun_account_verify(
    p_aid integer, p_pwd varchar, p_sid varchar
) RETURNS integer AS $$
declare
    p_tmp integer;
BEGIN

    select email.id into p_tmp
    from account inner join email on account.email_id = email.id
    where account.id = p_aid
        and account.password = p_pwd
        and account.verification_code = p_sid
        and account.verified = false;

    if not found then
        raise exception 'Invalid verification link';
    end if;

    update account 
    set status = true, verified = true,
        verified_date = current_timestamp 
    where id = p_aid;

    update email 
    set verified = true,
        verified_date = current_timestamp 
        where id = p_tmp;
    return p_aid;

END $$ language plpgsql;
