DROP TRIGGER tr_account_insert ON account;
CREATE TRIGGER tr_account_insert
    BEFORE INSERT ON account
    FOR EACH ROW EXECUTE PROCEDURE account_insert();
