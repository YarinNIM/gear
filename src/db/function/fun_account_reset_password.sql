select * from fun_dropfunction('fun_account_reset_password');
CREATE OR REPLACE FUNCTION fun_account_reset_password(
    p_aid integer, p_data jsonb) returns integer AS $$
declare
    p_tid integer;
BEGIN

    select account.id into p_tid
    from account 
    where id = p_aid 
        and password = p_data->>'pwd'
        and verification_code = p_data->>'sid'
        and verified = true
        and status = true;

    if not found then
        raise exception 'Invalid verification code';
    end if;

    update account 
    set password = p_data->>'password',
        verification_code = md5(p_data->>'password')
    where id = p_aid;

    return p_aid;
END $$ language plpgsql;
