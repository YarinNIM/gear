select * from fun_dropfunction('fun_admin_company_cover_update');
create or replace function fun_admin_company_cover_update(
    p_cover_id integer,
    p_cid integer,
    p_aid integer
) returns integer as $$
declare
begin
    perform fun_admin_validate_permission(p_aid, 'company.modify');
    update company
    set company_cover_id = p_cover_id
    where id = p_cid;

    return p_cover_id;
end $$ language plpgsql;
