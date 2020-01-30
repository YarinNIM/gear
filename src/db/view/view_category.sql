drop view view_category cascade;
create view view_category as
select
    cat.id, cat.category_key, cat.icon,
    concat(parent.name_en, ' >> ', cat.name_en) name_en,
    concat(parent.name_kh, ' >> ', cat.name_kh) as name_kh
from 
    product_category cat inner join (
        select id, name_en, name_kh
        from product_category
        where parent_id is null
        and status = true
    ) parent
    on cat.parent_id = parent.id;
