select * from fun_dropfunction('fun_account_email_update');
create or replace function fun_account_email_update(
    p_aid integer,
    p_email varchar
    ) returns integer as $$
declare
p_eid integer;
begin


    select account.email_id into p_eid
    from account inner join email on account.email_id = email.id
    where account.id != p_aid and lower(email.email)  = lower(p_email);

    if found then
        raise exception 'Email already used';
    end if;

    select id into p_eid
    from email 
    where lower(email) = lower(p_email);

    if not found then
        insert into email(email)
        values(lower(p_email));
        p_eid = currval('email_id_seq');
    end if;

    update account 
    set email_id = p_eid
    where id = p_aid;

    return p_aid;

end $$ language plpgsql;
