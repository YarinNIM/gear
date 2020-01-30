select * from fun_dropfunction('fun_delivery_agent_insert');
create or replace function fun_delivery_agent_insert(
    p_aid integer, p_props jsonb, p_by integer) returns integer as $$
declare 
    p_tmp integer;
begin

    select id into p_tmp
    from delivery_agent
    where account_id = p_aid and status = true;


    if found then
        raise exception 'This agent already exists';

    end if;

    select id into p_tmp
    from delivery_agent
    where account_id = p_aid and status = false;

    if found then
        update delivery_agent
        set created_by = p_by,
            is_agent = (p_props->>'is_agent')::boolean,
            description = p_props->>'description'

        where id = p_tmp;
    else
        insert into delivery_agent(account_id, description, is_agent, created_by)
        values(p_aid, p_props->>'description', (p_props->>'is_agent')::boolean, p_by);

        p_tmp := currval('delivery_agent_id_seq');
    end if;

    return p_tmp;

end $$ language plpgsql;
