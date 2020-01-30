select * from fun_dropfunction('fun_company_address_delete');
create or replace function fun_company_address_delete(
    p_cid integer, p_id integer) returns integer as $$
begin

    update company_address
    set status = false
    where company_id = p_cid and id = p_id;

    return p_id;

end $$ language plpgsql;
