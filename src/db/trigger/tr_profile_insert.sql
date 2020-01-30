DROP TRIGGER tr_profile_insert ON profile;
CREATE TRIGGER tr_profile_insert
    BEFORE INSERT ON profile 
    FOR EACH ROW EXECUTE PROCEDURE profile_insert();
