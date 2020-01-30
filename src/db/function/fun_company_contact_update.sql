select * from fun_dropfunction('fun_company_contact_update');
create or replace function fun_company_contact_update
(
    p_cid integer,
    p_contact jsonb
) returns integer as $$
begin
    update company 
    set email = p_contact->>'email',
        website  = p_contact->>'website',
        phone_number = p_contact ->>'phone_number'
    where id = p_cid;

    return p_cid;

end $$ language plpgsql;

