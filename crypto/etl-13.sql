
-- -----------------------------------------------------------------------------
-- 1.3. Decrypt/Extract Files
-- -----------------------------------------------------------------------------

create or replace function ETL_13() returns integer as $$
declare
    _nrows integer;

begin

    CREATE TABLE _ct_Files AS SELECT
        uid,
        folder_uid,
        mid,
        item_uid,
        fdecrypt(x_name)        as name,
        fdecrypt(x_desc)        as desc,
        content_type,
        isprofile,
        category,
        fdecrypt(x_form_data)   as form_data,
        modified_by,
        created,
        updated
    from Files;

    select count(*) into _nrows from _ct_Files;
    return _nrows;

end;
$$ language plpgsql;
