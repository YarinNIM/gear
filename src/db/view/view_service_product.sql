drop view view_service_product cascade;
create or replace view view_service_product as 
select 
    sp.company_id, sp.product_id as id,
    sp.selling_price,
    product.title, product.config,
    service.service_key,
    sp.status

from service_product sp inner join product on sp.product_id = product.id
    inner join service on sp.service_id = service.id;

    
