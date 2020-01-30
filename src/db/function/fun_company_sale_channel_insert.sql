select * from fun_dropfunction('fun_company_sale_channel_insert');
create or replace function fun_company_sale_channel_insert(
    p_cid integer, p_chn jsonb, p_aid integer
) returns integer as $$
declare
    p_tmp integer;
begin
    select id into p_tmp
    from company_sale_channel
    where company_id = p_cid
        and lower(name) = lower(p_chn->>'name');
    
    if found then
        raise exception 'Channel name already exists';
    end if;

    insert into company_sale_channel( company_id, name, description, account_id)
    values( p_cid, p_chn->>'name', p_chn->>'description', p_aid);

    return currval('company_sale_channel_id_seq');

end $$ language plpgsql;
