drop view view_product cascade;
create or replace view view_product as
select
    product.id, product.category_id, product.min_order,
    left(product.description, 50) as description,
    product.old_price, product.selling_price,product.sold_out,
    product.status,
    cat.name_en as category_en, cat.name_kh as category_kh, cat.category_key,
    product.company_id, 
    unit.code_en as unit_type_en, unit.code_kh as unit_type_kh,
    case
    when brand.name = 'other' then product.title
    else concat(brand.name, ' ', product.title)
    end as title,
    pic.url as picture_url

from product inner join view_category cat on product.category_id = cat.id
    inner join product_brand brand on product.brand_id = brand.id
    left outer join unit_type unit on unit.id = product.unit_type_id
    left outer join (
        select pp.id, pp.url, pp.product_id
        from (
            select id, product_id, url,
            row_number() over (partition by product_id order by product_id) num_row
            from product_picture
            group by 1,2
        ) pp where num_row = 1
    ) pic on pic.product_id = product.id


where product.company_id is not null;

