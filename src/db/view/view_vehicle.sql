drop view view_vehicle cascade;
create or replace view view_vehicle as
select
    v.id, v.description, v.status, v.plate_number,
    v.vehicle_model_id, v.color_id, v.province_id,
    province.name_en as province_en, v.year,
    concat(province.name_en, ' - ', v.plate_number) as plate_number_en,
    concat(province.name_kh, ' - ', v.plate_number) as plate_number_kh,
    concat(b.name, ' ', m.model_name, ' ', v.year) as model_name, m.model_number,
    color.name_en as color_en, color.name_kh as color_kh, color.rgb as color_rgb,
    pic.picture_url, pic.picture_title
from  vehicle v inner join vehicle_model m on m.id = v.vehicle_model_id
    inner join product_brand b on m.brand_id = b.id
    inner join color on v.color_id = color.id
    inner join province on v.province_id = province.id
    left outer join vehicle_picture pic on v.vehicle_picture_id = pic.id;
