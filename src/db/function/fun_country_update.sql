select * from fun_dropfunction('fun_country_update');
create or replace function fun_country_update(
    p_cid integer, p_country jsonb
) returns integer as $$
declare
    p_id integer;
begin
    select id into  p_id from country
    where (lower(country) = lower(p_country->>'country')
        or lower(name) = lower(p_country->>'name'))
        and id != p_cid;

    if found then
        raise exception 'Country name already exists';
    end if;

    select  id into p_id from country
    where lower(iso_code) = lower(p_country->>'iso_code')
        and id != p_id;
    
    if found then
        raise exception 'IOS Code already exists';
    end if;


    update country
    set country = p_country->>'country',
        name = p_country->>'name',
        code = p_country->>'code',
        iso_code = p_country->>'iso_code',
        status = (p_country->>'status')::boolean,
        is_delivery_destination = (p_country->>'is_delivery_destination')::boolean
    where id = p_cid;
    
    return p_cid;
end $$ language plpgsql;
