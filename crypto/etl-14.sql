
-- -----------------------------------------------------------------------------
-- 1.4. Decrypt/Extract Items
-- -----------------------------------------------------------------------------

create or replace function ETL_14() returns integer as $$
declare
    _nrows integer;

begin

    DROP TABLE IF EXISTS _ct_Items;

    CREATE TABLE _ct_Items as SELECT
        uid,
        mid,
        cid,
        folder_uid,
        app_uid,
        itemtype,
        fdecrypt(x_name)    as name,
        fdecrypt(x_desc)    as desc,
        created,
        updated,
        modified_by
    from Items;

    select count(*) into _nrows from _ct_Items;
    return _nrows;

end;
$$ language plpgsql;
