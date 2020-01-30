CREATE OR REPLACE FUNCTION account_insert() RETURNS TRIGGER AS $$
--DECLARE
BEGIN
    if not exists(select * from account where user_name = New.user_name) then
        return NEW;
    else
        -- raise exception 'User name already exits';
        -- raise notice 'User name already exits';
        -- RAISE unique_violation USING MESSAGE = 'USER NAME already exists, please verify a new one: [' || New.user_name || ']';
        RAISE EXCEPTION 'USER NAME [%] already exists',New.user_name;
    end if;
END $$ language plpgsql;
