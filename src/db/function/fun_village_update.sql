select * from fun_dropfunction('fun_village_update');
create or replace function fun_village_update(
    p_id integer, p_vil jsonb) returns integer as $$
declare
    p_tmp integer;
    p_did integer;
begin

    p_did := (p_vil->>'district_id')::integer;
    select id into p_tmp
    from village
    where (
        lower(name_en) = lower(p_vil->>'name_en') or lower(name_kh) = lower(p_vil->>'name_kh')
    ) and id != p_id and district_id = p_did;

    if found then 
        raise exception 'Village name already exists';
    end if;

    update village
    set name_en = p_vil->>'name_en',
        name_kh = p_vil->>'name_kh',
        status = (p_vil->>'status')::boolean,
        is_delivery_destination = (p_vil->>'is_delivery_destination')::boolean
    where id = p_id;

    return p_id;




end $$ language plpgsql;
