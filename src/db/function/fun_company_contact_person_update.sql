select * from fun_dropfunction('fun_company_contact_person_update');
create or replace function fun_company_contact_person_update(
    p_cid integer, p_id integer, p_person jsonb) returns integer as $$
declare
    p_tmp integer;
begin

    select id into p_tmp
    from company_contact_person
    where lower(first_name) = lower(p_person->>'first_name')
        and lower(last_name) = lower(p_person->>'last_name')
        and company_id = p_cid and id != p_id;

    if found then
        raise exception 'Contact person already exists';
    end if;

    select 
        id into p_tmp
    from 
        company_contact_person
    where 
        mobile = p_person->>'mobile'
        and company_id = p_cid
        and id != p_id;

    if found then
        raise exception 'Mobile phone taken';
    end if;

    select id into p_tmp
    from company_contact_person
    where email_address = lower(p_person->>'email_address')
        and company_id = p_cid and length(p_person->>'email_address') > 0
        and id != p_id;

    if found then
        raise exception 'Email address already used';
    end if;

    update company_contact_person
    set
        person_title_id = (p_person->>'person_title_id')::integer,
        position_title = p_person->>'position_title',
        first_name = p_person->>'first_name',
        last_name = p_person->>'last_name',
        sex = p_person->>'sex',
        mobile = p_person->>'mobile',
        email_address= p_person->>'email_address'
    where company_id = p_cid and id = p_id;

    return p_id;
    
end $$ language plpgsql; 
