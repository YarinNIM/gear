select * from fun_dropfunction('fun_product_picture_select');
create or replace function fun_product_picture_select(
    p_pid integer, p_pic_id integer) returns integer as $$
declare
    p_tmp integer;
begin

    select id into p_tmp
    from product
    where array[p_pic_id] <@ pictures
    and id = p_pid;

    if found then 
        raise exception 'Picture already exists';
    end if;

    update product
    set pictures = array_append(pictures, p_pic_id)
    where id = p_pid;

    return p_pic_id;

end $$ language plpgsql;
