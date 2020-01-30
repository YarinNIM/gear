select * from fun_dropfunction('fun_product_picture_insert');
create or replace function fun_product_picture_insert(
    p_pid integer, 
    p_url varchar, p_title varchar,
    p_aid integer) returns integer as $$
begin
    insert into product_picture(product_id, url,title, account_id )
    values(p_pid, p_url, p_title, p_aid);

    return  currval('product_picture_id_seq');

end $$ language plpgsql;
