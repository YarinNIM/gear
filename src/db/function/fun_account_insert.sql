select * from fun_dropfunction('fun_account_insert');
create or replace function fun_account_insert(
    p_account jsonb,
    p_aid integer
) returns integer as $$
declare
p_id integer;
p_email_id integer;
p_phone_id integer;

p_birthdate date;
p_phone_country_id integer;
begin

    select account.id into p_id
    from account 
    left outer join email on account.email_id = email.id
    where lower(email.email) = lower(p_account->>'email') and length(p_account->>'email') > 0;

    if found then
        raise exception 'Email already taken';
    end if;

    select account.id into p_id
    from account left outer join phone on account.phone_id = phone.id
    where phone.phone = p_account->>'phone' and length(p_account->>'phone') > 0;

    if found then
        raise exception 'Phone number already taken';
    end if;

    p_birthdate = p_account->'birthdate';

    insert into account(first_name, last_name, sex, birthdate, about, verified, is_account, created_by)
    values(
        p_account->>'first_name',
        p_account->>'last_name',
        p_account->>'sex',
        p_birthdate, p_account->>'about',
        false, false,
        p_aid
    );
    p_id := currval('account_id_seq');

    -- check phone exists
    if length(p_account->>'phone') > 0 then
        select id into p_phone_id
        from phone where phone = p_account->>'phone';

        if not found then
            p_phone_country_id = p_account->'phone_country_id';
            insert into phone(country_id, phone)
            values(
                p_phone_country_id,
                p_account->>'phone'
            );

            p_phone_id := currval('phone_id_seq');
        end if;

        update account set phone_id = p_phone_id
        where id = p_id;
    end if;

    -- check if email exists
    if length(p_account->>'email') > 0 then
        select id into p_email_id
        from email
        where lower(email) = lower(p_account->>'email');

        if not found then
            insert into email(email)
            values(lower(p_account->>'email'));
            p_email_id := currval('email_id_seq');
        end if;

        update account 
        set email_id = p_email_id
        where id = p_id;
    end if;

    return p_id;
end $$ language plpgsql;
