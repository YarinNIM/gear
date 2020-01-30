select * from fun_dropfunction('fun_product_insert');
create or replace function fun_product_insert(
    p_cid integer, p_pro jsonb,  p_aid integer) returns integer as $$
declare
    p_tmp integer;
begin

    select id into p_tmp
    from product
    where lower(title) = lower(p_pro->>'title')
        and company_id = p_cid
        and category_id = (p_pro->>'category_id')::integer
        and brand_id = (p_pro->>'brand_id')::integer;

    if found then
        raise exception 'Product already exists';
    end if;
    
    insert into product( 
        account_id,
        company_id, 
        category_id, 
        brand_id, 
        model_id,
        model_name,
        barcode,
        title, 
        description)
    values(
        p_aid,
        p_cid,
        (p_pro->>'category_id')::integer,
        (p_pro->>'brand_id')::integer,
        nullif((p_pro->>'model_id')::integer,0),
        p_pro->>'model_name',
        p_pro->>'barcode',
        p_pro->>'title',
        p_pro->>'description');

    return currval('product_id_seq');

end $$ language plpgsql;
