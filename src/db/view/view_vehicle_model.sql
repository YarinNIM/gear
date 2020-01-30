drop view view_vehicle_model;
create view view_vehicle_model as
select
    model.id, 
    concat(brand.name, ' ', model.model_name) as model_name,
    model.status
from  vehicle_model model inner join product_brand brand on model.brand_id = brand.id;
