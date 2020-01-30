select * from fun_dropfunction('fun_company_sale_channel_update');
create or replace function fun_company_sale_channel_update(
    p_cid integer, p_chn_id integer, p_chn jsonb) returns integer as $$
declare
    p_tmp integer;
begin
    
    select id into p_tmp
    from company_sale_channel
    where lower(name) = lower(p_chn->>'name')
        and company_id = p_cid
        and id != p_chn_id;

    if found then 
        raise exception 'Channel name already exists';
    end if;

    update company_sale_channel
    set 
        name = p_chn->>'name',
        description = p_chn->>'description'
    where company_id = p_cid
        and id = p_chn_id;

    return p_chn_id;

end $$ language plpgsql;
