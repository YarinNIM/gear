drop view view_company;
create view view_company as
select 
    com.id, com.name_en, com.name_kh, 
    com.desc_en, com.desc_kh, com.status, 
    com.industry_type_id, com.company_type_id,
    com.phone_number, com.email, com.website, 
    com.company_address_id as address_id,

    industry.name_en industry_en, industry.name_kh industry_kh,
    type.name_en company_type_en, type.name_kh company_type_kh,
    cover.url cover_url, logo.url logo_url

from company com inner join company_type type on com.company_type_id = type.id
    inner join industry_type industry on com.industry_type_id = industry.id
    left outer join company_cover cover on com.company_cover_id = cover.id
    left outer join company_logo logo on logo.id = com.company_logo_id


