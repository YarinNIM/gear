select * from fun_dropfunction('fun_village_insert');
create or replace function fun_village_insert(
    p_did integer, p_vil jsonb) returns integer as $$
declare
    p_id integer;
begin
    
    select id into p_id
    from village
    where (
            lower(name_en) = lower(p_vil->>'name_en') or
            lower(name_kh) = lower(p_vil->>'name_kh')
        ) and district_id = p_did;
    
    if found then
        raise exception 'Village name already exists';
    end if;

    insert into village(
        district_id, name_en, name_kh, 
        status, is_delivery_destination)
    values(
        p_did, p_vil->>'name_en', p_vil->>'name_kh', 
        (p_vil->>'status')::boolean,
        (p_vil->>'is_delivery_destination')::boolean
    );

    return currval('village_id_seq');
    
end $$ language plpgsql;
