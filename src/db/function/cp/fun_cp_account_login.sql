select * from fun_dropfunction('fun_cp_account_login');
create or replace function fun_cp_account_login(
    p_id varchar,
    p_pwd varchar
)returns integer as $$
declare
    p_aid integer;
    p_cid integer;
begin
    p_aid = fun_account_login(p_id, p_pwd);
    select id into p_cid
    from company_account
    where account_id = p_aid;

    if not found then
        raise exception 'Account not belong to any company';
    end if;

    return p_aid;

end $$ language plpgsql;
