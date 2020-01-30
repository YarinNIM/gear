select * from fun_dropfunction('fun_admin_company_insert');
create or replace function fun_admin_company_insert(
    p_com jsonb,
    p_aid integer,
    p_perm varchar
) returns integer as $$
declare
    p_cid integer;
    p_type_id integer;
    p_ind_id integer;
begin
    perform fun_admin_validate_permission(p_aid, p_perm);

    select id into p_cid
    from company
    where lower(name_en) = lower(p_com->>'name_en');

    if found then
        raise exception 'Company name already exists';
    end if;

    p_ind_id = p_com->'industry_type_id';
    p_type_id = p_com->'company_type_id';

    insert into company(
        name_en, name_kh, 
        company_type_id, industry_type_id, 
        desc_en, account_id)
    values(
        p_com->>'name_en', p_com->>'name_kh',
        p_type_id, p_ind_id,
        p_com->>'desc_en',
        p_aid);

    return currval('company_id_seq');
    
end $$ language plpgsql;
    
