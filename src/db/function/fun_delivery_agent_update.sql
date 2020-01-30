select * from fun_dropfunction('fun_delivery_agent_update');
create or replace function fun_delivery_agent_update(
    p_aid integer, p_props jsonb, p_by integer) returns integer as $$
begin

    update delivery_agent
    set description = p_props->>'description',
        is_agent = (p_props->>'is_agent')::boolean,
        status = true,
        created_by = p_by
    where account_id = p_aid;

    return p_aid;
end $$ language plpgsql;
