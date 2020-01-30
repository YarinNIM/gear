drop view view_fleet_service_detail_service cascade;
create or replace view view_fleet_service_detail_service as

select distinct detail.id, detail.fleet_service_id, detail.km_to_use,
    pro.title, pro.config->>'picture_url' as picture_url
from 
    -- fleet_service_detail detail inner join service_product pro on pro.id = detail.product_id;
    fleet_service_detail detail inner join view_service_product pro on pro.id = detail.product_id;
