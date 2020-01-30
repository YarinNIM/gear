CREATE OR REPLACE FUNCTION profile_insert() RETURNS TRIGGER AS $$
--DECLARE
BEGIN
    IF NOT EXISTS(SELECT * FROM profile WHERE name = New.name) THEN
        IF length(New.name) < 5 THEN
            RAISE EXCEPTION 'Profile name is too short. It must be at least 5 characters long!' USING ERRCODE ='HV090';
        ELSEIF length(New.description) <= 30 THEN
            RAISE EXCEPTION 'Description is too short, > 30 character long' USING ERRCODE = 'HV090';
        ELSE
            RETURN NEW;
        END IF;
    ELSE
        -- raise exception 'User name already exits';
        -- raise notice 'User name already exits';
        -- RAISE unique_violation USING MESSAGE = 'USER NAME already exists, please verify a new one: [' || New.user_name || ']';
        RAISE EXCEPTION 'PROFILE NAME [%] already exists',New.name;
    end if;
END $$ language plpgsql;
