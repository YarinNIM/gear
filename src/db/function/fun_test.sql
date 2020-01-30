select * from fun_dropfunction('fun_test');
create or replace function fun_test(
    p_num integer
) returns integer as $$
declare
p_val integer;
begin
    p_val = fun_test_re(p_num);
    return p_val;

end $$ language plpgsql;
