select * from fun_dropfunction('fun_delivery_company_unsubscribe');
create or replace function fun_delivery_company_unsubscribe(
    p_cid integer, p_com jsonb, p_aid integer
) returns integer as $$
declare
    p_tmp integer;
begin
        
    select id into p_tmp
    from company 
    where 
        delivery_subscriber = false
        and id = p_cid;
    
    if found then
        raise exception 'Company not in subscriber list';
    end if;

    update company set delivery_subscriber = false
    where id = p_cid;

    insert into delivery_company_subscription(company_id, description, by_account_id)
    values(p_cid, p_com->>'reason', p_aid);

    return currval('delivery_company_subscription_id_seq');

end $$ language plpgsql;

