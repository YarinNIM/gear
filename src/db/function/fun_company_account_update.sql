select * from fun_dropfunction('fun_company_account_update');
create or replace function fun_company_account_update(
    p_cid integer, p_aid integer, p_rid integer) returns integer as $$
declare
    p_tmp integer;
begin

end $$ language plpgsql;
