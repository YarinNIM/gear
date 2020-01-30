select * from fun_dropfunction('fun_delivery_subscriber_update');
create or replace function fun_delivery_subscriber_update(
    p_cid integer, p_props jsonb, p_aid integer) returns integer as $$
begin

    update delivery_subscriber
    set description = p_props->>'description'
    where company_id = p_cid;

    return p_cid;
end $$ language plpgsql;
