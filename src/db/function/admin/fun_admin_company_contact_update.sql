select * from fun_dropfunction('fun_admin_company_contact_update');
create or replace function fun_admin_company_contact_update
(
    p_contact jsonb,
    p_cid integer,
    p_aid integer,
    p_perm varchar
) returns integer as $$
begin
    perform fun_admin_validate_permission(p_aid, p_perm);

    update company 
    set email = p_contact->>'email',
        website  = p_contact->>'website',
        phone_number = p_contact ->>'phone_number'
        -- company_address_id = p_contact->'address_id'

    where id = p_cid;

    return p_cid;

end $$ language plpgsql;

