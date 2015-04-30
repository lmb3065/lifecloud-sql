
-- -----------------------------------------------------------------------------
-- 1.1. Decrypt/Extract Members
-- -----------------------------------------------------------------------------

create or replace function ETL_11() returns integer as $$
declare
    _nrows integer;
    
begin

    DROP TABLE IF EXISTS _ct_Members;

    CREATE TABLE _ct_Members AS SELECT
        mid,
        cid,
        h_passwd,
        fdecrypt(x_userid)      as userid,
        fdecrypt(x_email)       as email,
        h_profilepic,
        fdecrypt(x_fname)       as fname,
        fdecrypt(x_mi)          as mi,
        fdecrypt(x_lname)       as lname,
        fdecrypt(x_address1)    as address1,
        fdecrypt(x_address2)    as address2,
        fdecrypt(x_city)        as city,
        fdecrypt(x_state)       as state,
        fdecrypt(x_postalcode)  as postalcode,
        fdecrypt(x_country)     as country,
        fdecrypt(x_phone)       as phone,
        alerttype,
        fdecrypt(x_alertphone)  as alertphone,
        fdecrypt(x_alertemail)  as alertemail,
        status,
        pwstatus,
        userlevel,
        tooltips,
        isadmin,
        logincount,
        created,
        updated
    from Members;

    select count(*) into _nrows from _ct_Members;
    return _nrows;

end;
$$ language plpgsql;
