select * from fun_dropfunction('fun_account_update');
create or replace function fun_account_update(
    p_id integer,
    p_account jsonb,
    p_aid integer
) returns integer as $$
begin

    update account 
    set first_name = p_account->>'first_name',
        last_name = p_account->>'last_name',
        sex = p_account->>'sex',
        about = p_account->>'about',
        birthdate = (p_account->>'birthdate')::timestamp
    where id = p_id;

    return p_id;

end $$ language plpgsql;
