select * from fun_dropfunction('fun_product_general_info_update');
create or replace function fun_product_general_info_update(
    p_id integer, p_pro jsonb) returns integer as $$
declare
    p_tmp integer;
begin

    select product.id into p_tmp
    from product, (select company_id  as id from product where id = p_id) company
    where lower(product.title) = lower(p_pro->>'title')
        and product.category_id = (p_pro->>'category_id')::integer
        and product.brand_id = (p_pro->>'brand_id')::integer
        and product.id != p_id
        and product.company_id = company.id;

    if found then
        raise exception 'Product already exists';
    end if;
    
    update product 
    set
        model_id = nullif((p_pro->>'model_id')::integer,0),
        model_name = p_pro->>'model_name',
        barcode = p_pro->>'barcode',
        title = p_pro->>'title',
        brand_id = (p_pro->>'brand_id')::integer,
        description = p_pro->>'description'
    where id = p_id;

    return p_id;

end $$ language plpgsql;
