drop view view_company_fleet_service;
create view view_company_fleet_service as

select
    cfs.id, cfs.company_id, cfs.service_id, cfs.price as selling_price,
    svc.name_en as title_en, svc.name_kh as title_kh, svc.picture_url,
    svc.require, svc.service_key
from
    company_fleet_service cfs inner join fleet_service svc on svc.id = cfs.service_id
where svc.status = true;
