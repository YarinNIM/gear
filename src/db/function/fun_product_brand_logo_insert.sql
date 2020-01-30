select * from fun_dropfunction('fun_product_brand_logo_insert');
create or replace function fun_product_brand_logo_insert(
    p_name varchar,
    p_logo varchar, 
    p_aid integer
) returns integer as $$
begin
    insert into product_brand(name, logo_url, company_name, account_id)
    values(p_name, p_logo, p_name, p_aid);

    return currval('product_brand_id_seq');
end $$ language plpgsql;
