drop view view_fleet_service_detail cascade;
create or replace view view_fleet_service_detail as

select 
    detail.id, detail.fleet_service_id, detail.qty, detail.attached_to,
    pro.id as product_id, pro.title, pro.unit_type_en

from 
    fleet_service_detail detail inner join view_product pro on pro.id = detail.product_id;
