select * from fun_dropfunction('fun_test_re'); 
create or replace function fun_test_re (
    p_num integer
) returns integer as $$
begin
    if p_num > 10 then
        return p_num;
    else
        raise exception 'ERrror';
    end if;
end $$ language plpgsql;
