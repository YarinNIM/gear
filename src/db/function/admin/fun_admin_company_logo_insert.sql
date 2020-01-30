select * from fun_dropfunction('fun_admin_company_logo_insert');
create or replace function fun_admin_company_logo_insert(
    p_url varchar,
    p_cid integer,
    p_aid integer
) returns integer as $$
declare
    p_logo_id integer;
begin
    perform fun_admin_validate_permission(p_aid, 'company.modify');
    insert into company_logo(url, company_id, account_id)
    values(p_url, p_cid, p_aid);

    p_logo_id = currval('company_logo_id_seq');

    update company
    set company_logo_id = p_logo_id
    where id = p_cid;

    return p_logo_id;

end $$ language plpgsql;


