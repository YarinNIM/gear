drop view view_fleet_service cascade;
create or replace view  view_fleet_service as

select fs.id, fs.created_date, fs.start_date, fs.finish_date,
    fs.vehicle_id, fs.vehicle_odometer, fs.invoice_id,
    inv.company_id, inv.customer_id, inv.customer_company_id,
    vehicle.model_name, vehicle.plate_number
from fleet_service fs inner join invoice inv on fs.invoice_id = inv.id
    inner join view_vehicle vehicle on fs.vehicle_id = vehicle.id;
