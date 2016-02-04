
-- ======================================================================
-- type account_ext_t                             (account extended type)
-- ----------------------------------------------------------------------
-- contains an unencrypted row from Accounts
--  AND the row from Members (owner_mid->members.mid) that is the Owner
-- ======================================================================

-- 2013-10-02 dbrown added accout_referrer
-- 2016-01-29 dbrown added payment_type

drop type account_ext_t cascade;

create type account_ext_t as (

    cid             int,
    account_status  int,
    account_quota   bigint,
    account_referrer varchar,
    account_payment_type varchar,
    account_created timestamp,
    account_updated timestamp,
    account_expires timestamp,
    member_count    int,
    owner_mid       int,
    userid          text,
    email           text,
    fname           text,
    mi              text,
    lname           text,
    address1        text,
    address2        text,
    city            text,
    state           text,
    postalcode      text,
    country         text,
    phone           text,
    owner_mstatus     int,
    owner_pwstatus    int,
    owner_userlevel   int,
    owner_tooltips    int,
    owner_isadmin     int,
    owner_logincount  int,
    owner_created     timestamp,
    owner_updated     timestamp,
    nrows             int,
    npages            int
);

alter type account_ext_t owner to pgsql;

