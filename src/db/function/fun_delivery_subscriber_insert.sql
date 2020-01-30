select * from fun_dropfunction('fun_delivery_subscriber_insert');
create or replace function fun_delivery_subscriber_insert(
    p_cid integer, p_props jsonb, p_aid integer) returns integer as $$
declare
    p_tmp integer;
begin

    select id into p_tmp 
    from delivery_subscriber
    where status = true
        and company_id = p_cid;
    
    if found then
        raise exception 'Company already in subscriber list';
    end if;

    select id into p_tmp
    from delivery_subscriber 
    where status = false and company_id = p_cid;

    if found then
        update delivery_subscriber
        set description = p_props->>'description',
            status = true,
            created_by = p_aid,
            created_date = current_timestamp
        where id = p_tmp;
        return p_tmp;
    else
        insert into delivery_subscriber(company_id, description,created_by) 
        values(p_cid, p_props->>'description', p_aid);
        return currval('delivery_subscriber_id_seq');
    end if;


end $$ language plpgsql;
