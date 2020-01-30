select * from fun_dropfunction('fun_account_phone_update');
create or replace function fun_account_phone_update(
    p_id integer,
    p_phone varchar
    ) returns integer as $$
declare
p_pid integer;
begin

    select account.phone_id into p_pid
    from account inner join phone on account.phone_id = phone.id
    where account.id != p_id and phone.phone = p_phone;

    if found then
        raise exception 'Phone already used';
    end if;

    select id into p_pid
    from phone
    where phone = p_phone;

    if not found then
        insert into phone(phone)
        values(p_phone);
        p_pid = currval('phone_id_seq');
    end if;

    update account 
    set phone_id = p_pid
    where id = p_id;

    return p_id;

end $$ language plpgsql;
