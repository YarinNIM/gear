select * from fun_dropfunction('fun_company_contact_person_insert');
create or replace function fun_company_contact_person_insert(
    p_cid integer,
    p_person jsonb,
    p_aid integer) returns integer as $$
declare
    p_tmp integer;
begin
    select id into p_tmp
    from company_contact_person
    where (lower(first_name) = lower(p_person->>'first_name')
        and lower(last_name) = lower(p_person->>'last_name')
        and company_id = p_cid) ;

    if found then
        raise exception 'Contact Person already exits';
    end if;

    
    select id into p_tmp
    from company_contact_person
    where (mobile = p_person->>'mobile' and company_id = p_cid);
    if found then
        raise exception 'Mobile phone taken by a contact';
    end if;

    select id into p_tmp
    from company_contact_person
    where (email_address = lower(p_person->>'email_address') 
        and company_id = p_cid and length(p_person->>'email_address') > 0);
    if found then
        raise exception 'Email address already used by a contact';
    end if;

    
    insert into company_contact_person(
        company_id, 
        account_id,
        person_title_id,
        position_title,
        first_name,
        last_name,
        sex,
        mobile,
        email_address)
    values(
        p_cid, p_aid,
        (p_person->>'person_title_id')::integer,
        p_person->>'position_title',
        p_person->>'first_name',
        p_person->>'last_name',
        p_person->>'sex',
        p_person->>'mobile',
        lower(p_person->>'email_address')
    );

    return currval('company_contact_person_id_seq');

end $$ language plpgsql;
