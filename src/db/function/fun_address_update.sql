select * from fun_dropfunction('fun_address_update');
create or replace function fun_address_update(
    p_addr_id integer, p_addr jsonb, p_aid integer
) returns integer as $$ 
declare
    p_tmp integer;
begin

    select id into p_tmp
    from address
    where lower(address) = lower(p_addr->>'address')
        and id != p_addr_id 
        and created_by = p_aid;

    if found then
        raise exception 'Address already exists';
    end if;

    update address 
    set address_name = p_addr->>'address_name',
        address = p_addr->>'address',
        location = p_addr->>'location',
        village_id = (p_addr->>'village_id')::integer
    where id = p_addr_id;

    return p_addr_id;
end $$ language plpgsql;
