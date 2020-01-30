select * from fun_dropfunction('fun_product_category_spec_insert');
create or replace function fun_product_category_spec_insert(
    p_cid integer, p_sid integer) returns integer as $$
declare
    p_tmp integer;
begin

    select id into p_tmp
    from product_category
    where array[p_sid] <@ product_specs
        and id = p_cid;

    if found then
        raise exception 'Specification already exists';
    end if;

    update product_category
    set product_specs = array_append(product_specs, p_sid)
    where id = p_cid;

    return p_sid;


end $$ language plpgsql;
