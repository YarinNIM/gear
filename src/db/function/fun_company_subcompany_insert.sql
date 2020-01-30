select * from fun_dropfunction('fun_admin_company_sub_company_insert');
create or replace function fun_admin_company_sub_company_insert(
    p_cid integer,
    p_sid integer) returns integer as $$
begin

    update company
    set parent_company_id = p_cid
    where id = p_sid and parent_company_id is null;
    
    return p_sid;
end $$ language plpgsql;
