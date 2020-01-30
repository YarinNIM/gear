select * from fun_dropfunction('fun_admin_company_update');
create or replace function fun_admin_company_update(
    p_name_en varchar, p_name_kh varchar,
    p_type_id integer, p_ind_id integer,
    p_desc_en varchar, 
    p_cid integer, p_aid integer, p_perm varchar
) returns integer as $$
declare
    p_tmp integer;
begin

    perform fun_admin_validate_permission(p_aid, p_perm);
    select com.id into p_tmp
    from company com
    where lower(com.name_en) = lower(p_name_en)
        and com.id <> p_cid;
    
    if found then
        raise exception 'Company name already exists';
    end if;

    update company
    set name_en = p_name_en, name_kh = p_name_kh,
        company_type_id = p_type_id, industry_type_id = p_ind_id,
        desc_en = p_desc_en
    where id = p_cid;

    return p_cid;


end $$ language plpgsql;
