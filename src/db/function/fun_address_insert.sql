select * from fun_dropfunction('fun_address_insert');
create or replace function fun_address_insert(
    p_addr jsonb, p_aid integer) returns integer as $$
declare
    p_tmp integer;
begin

    select id into p_tmp
    from address
    where 
        lower(address) = lower(p_addr->>'address')
        and village_id = (p_addr->>'village_id')::integer;

    if found then
        raise exception 'Address already exists';
    end if;

    insert into address(created_by, address_name, address, village_id, location)
    values(p_aid,
        p_addr->>'address_name',
        p_addr->>'address',
        (p_addr->>'village_id')::integer, 
        p_addr->>'location');

    return currval('address_id_seq');

end $$ language plpgsql;
