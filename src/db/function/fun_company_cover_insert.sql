select * from fun_dropfunction('fun_company_cover_insert');
create or replace function fun_company_cover_insert(
    p_cid integer,
    p_url varchar,
    p_aid integer
) returns integer  as $$
declare
p_cover_id integer;
begin
    insert into company_cover(url, company_id, account_id)
    values(p_url, p_cid, p_aid);

    p_cover_id = currval('company_cover_id_seq');

    update company set company_cover_id = p_cover_id
    where id = p_cid;

    return p_cover_id;
end $$ language plpgsql;
