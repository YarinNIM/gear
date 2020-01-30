select * from fun_dropfunction('fun_or_order_create');
create or replace function fun_or_order_create(
    p_orders jsonb[], p_del jsonb, p_del_addr jsonb, p_aid integer)
) returns integer[] as $$
declare
    p_ids integer[];
begin 
end $$ language plpgsql;
