
-- -----------------------------------------------------------------------------
-- 1.2. Decrypt/Extract Folders
-- -----------------------------------------------------------------------------

create or replace function ETL_12() returns integer as $$
declare
    _nrows integer;

begin

    DROP TABLE IF EXISTS _ct_Folders;

    CREATE TABLE _ct_Folders AS SELECT
        uid,
        mid,
        cid,
        fdecrypt(x_name)    as name,
        fdecrypt(x_desc)    as desc,
        app_uid,
        created,
        updated
    from Folders;

    select count(*) into _nrows from _ct_Folders;
    return _nrows;

end;
$$ language plpgsql;
