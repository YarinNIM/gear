select * from fun_dropfunction('fun_product_model_move');
create or replace function fun_product_model_move(
    p_id integer, p_cid integer) returns integer as $$
declare
    p_tmp integer;
begin

    select model.id into p_tmp
    from 
        product_model model, 
        (select * from product_model where id = p_id) selected

    where model.id != p_id
        and model.category_id = p_cid
        and model.brand_id = selected.brand_id;


    if found then
        raise exception 'Model already exist in this category';
    end if;

    update product_model
    set category_id = p_cid
    where id = p_id;

    return p_id;
end $$ language plpgsql;
