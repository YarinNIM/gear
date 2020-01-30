select * from fun_dropfunction('fun_cp_account_login');
CREATE FUNCTION public.fun_cp_account_login(
    p_email character varying, p_pwd character varying) RETURNS integer LANGUAGE plpgsql AS $$
declare
    p_aid integer;
    p_cid integer;
begin
    p_aid = fun_account_login(p_email, p_pwd);

    select id into p_cid
    from company_account
    where account_id = p_aid;

    

    if not found then
        raise exception 'Account not belong to any company';
    end if;

    return p_aid;

end $$;


