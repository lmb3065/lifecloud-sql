
-- --------------------------------------------------------------------------
--  MEMBERS                                                            Table
-- --------------------------------------------------------------------------
--  Members can LOG IN.  Members belong to an ACCOUNT.
--  Columns prepended with x_ contain PGP-encrypted string data.
--  Column  prepended with h_ contain SHA-hashed string data.
-- pwstatus: 0 = OK / 1 = Must be changed
-- --------------------------------------------------------------------------
-- 2013-09-25 dbrown : Encrypted fields moved here from Accounts table,
--                     UID renamed to MID, defaults set for non-X fields
-- 2013-10-18 dbrown : added column profilepic, reordered some columns

create table Members
(
    mid         serial      primary key,
    cid         int         references Accounts,
    
    h_passwd    text        not null,
    x_userid    bytea       not null,
    x_email     bytea       not null,
    h_profilepic text,

    x_fname     bytea       not null,
    x_mi        bytea       not null,
    x_lname     bytea       not null,

    x_address1  bytea       not null,
    x_address2  bytea       not null,
    x_city      bytea       not null,
    x_state     bytea       not null,
    x_postalcode bytea      not null,
    x_country   bytea       not null,
    x_phone     bytea       not null,
    
    status      int         not null   default 0, -- : Normal, able to log in
    pwstatus    int         not null   default 0, -- : Not expired, does not need to be changed
    userlevel   int         not null   default 4, -- : Guest (view items only)
    tooltips    int         not null   default 1, -- : Show tooltips
    isadmin     int         not null   default 0, -- : Is not an admin account
    logincount  int         not null   default 0, -- : Has never logged in
    created     timestamp   not null   default now(),
    updated     timestamp   not null   default now()
);
alter table Members owner to pgsql;

