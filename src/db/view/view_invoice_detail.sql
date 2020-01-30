drop view view_invoice_detail;
create view view_invoice_detail as
select 
    detail.id, detail.invoice_id, detail.product_id, 
    detail.unit_price, detail.qty, detail.discount, detail.attached_to,

    unit.code_en as unit_type_en,
    case
        when brand.name = 'other' then product.title
        else concat(brand.name, ' ', product.title)
    end as title

from invoice_detail detail inner join product on detail.product_id = product.id
    left outer join product_brand brand on product.brand_id = brand.id
    left outer join unit_type unit on unit.id = product.unit_type_id;
