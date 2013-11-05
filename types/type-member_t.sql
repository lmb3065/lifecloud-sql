
-- =============================================================================
-- type member_t
-- -----------------------------------------------------------------------------
-- contains an unencrypted row from Members
-- -----------------------------------------------------------------------------
-- 2013-10-18 dbrown : new column 'profilepic'; reordered some fields
-- 2013-10-31 dbrown : changed varchar columns to text
-- -----------------------------------------------------------------------------

create type member_t as (

    mid         int,
    cid         int,

    fname       text,
    lname       text,
    mi          text,
    
    userid      text,
    email       text,
    h_profilepic text, -- HASHED (40 chars)
    
    address1    text,
    address2    text,
    city        text,
    state       text,
    postalcode  text,
    country     text,
    phone       text,

    status      int,
    pwstatus    int,
    userlevel   int,
    tooltips    int,
    isadmin     int,
    logincount  int,
    
    created     timestamp,
    updated     timestamp
);

alter type member_t owner to pgsql;

