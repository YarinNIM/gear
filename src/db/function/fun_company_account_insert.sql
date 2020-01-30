select * from fun_dropfunction('fun_company_account_insert');
create or replace function fun_company_account_insert(
    --p_cid integer, p_email varchar, p_rid integer, p_aid integer) returns integer as $$
    p_cid integer, p_account jsonb, p_aid integer) returns integer as $$
declare
    p_tmp integer;
    p_tmp1 integer;
begin
    
    select account.id into p_tmp
    from account inner join email on account.email_id = email.id
    where account.status = true
        and account.verified = true
        and lower(email.email) = lower(p_account->>'email');

    if not found then
        raise exception 'No account associated with this email';
    end if;

    select id into p_tmp1
    from company_account
    where company_id = p_cid
        and account_id = p_tmp;

    if found then
        raise exception 'Account already exists';
    end if;


    insert into company_account(
        company_id, account_id,
        position_title,
        role_id, created_by)
    values(
        (p_account->>'company_id')::integer, p_tmp, 
        p_account->>'position_title',
        (p_account->>'role_id')::integer, p_aid);

    return p_tmp;


end $$ language plpgsql;
