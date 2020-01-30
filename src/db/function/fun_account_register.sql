select * from fun_dropfunction('fun_account_register');
CREATE OR REPLACE FUNCTION fun_account_register(
    p_ac jsonb, p_sid varchar) RETURNS integer AS $$
declare
    p_aid integer;
    p_eid integer;
BEGIN

    -- If the accont already exists
    select account.email_id into p_eid
    from account inner join email on account.email_id = email.id
    where lower(email.email) = lower(p_ac->>'email');

    -- Raise error if account exists
    if found then
        raise exception 'Email already exists';
    end if;

    -- select email id
    select id into p_eid
    from email where lower(email) = lower(p_ac->>'email');

    -- if email not exists, create one
    if not found then
        insert into email(email)
        values(lower(p_ac->>'email'));
        p_eid := currval('email_id_seq');
    end if;

    -- insert account
    INSERT INTO account(
        first_name, last_name, sex, email_id,
        password, birthdate, verification_code
    ) values(
        p_ac->>'first_name',
        p_ac->>'last_name',
        p_ac->>'sex',
        p_eid,
        p_ac->>'password',
        (p_ac->>'birthdate')::timestamp,
        p_sid
    );

    p_aid := currval('account_id_seq');
    return p_aid;
END $$ language plpgsql;
