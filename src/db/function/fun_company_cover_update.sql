select * from fun_dropfunction('fun_admin_company_cover_update');
create or replace function fun_admin_company_cover_update(
    p_cid integer,
    p_cover_id integer
) returns integer as $$
declare
begin

    update company
    set company_cover_id = p_cover_id
    where id = p_cid;

    return p_cover_id;
end $$ language plpgsql;
