-- --------------------------------------------------------------------------
--  MEMBERS                                                            Table
-- --------------------------------------------------------------------------
--   o  Members can LOG IN.  Members belong to an ACCOUNT.
--   o  Columns prepended with x_ contain PGP-encrypted string data.
--   o  Columns prepended with h_ contain SHA1 hashes of string data.
-- status: 0 = OK / 1 = Cannot login
-- pwstatus: 0 = OK / 1 = Must be changed
-- userlevel: 1 = Admin, 2 = Proxy, 3 = User, 4 = Viewer
-- --------------------------------------------------------------------------
-- 2013-09-25 dbrown : Encrypted fields moved here from Accounts table,
--                     UID renamed to MID, defaults set for non-X fields
-- 2013-10-18 dbrown : added column profilepic, reordered some columns
-- 2014-01-09 dbrown : removed NOT NULL constrants from optional x_ fields
-- 2014-03-24 dbrown : new fields alerttype, x_alertphone, x_alertemail
-----------------------------------------------------------------------------
create table Members
(
    mid         serial      primary key,
    cid         int         references Accounts,

    h_passwd    text        not null,
    x_userid    bytea       not null,
    x_email     bytea       not null,
    h_profilepic text,

    x_fname     bytea       not null,
    x_mi        bytea,
    x_lname     bytea       not null,

    x_address1  bytea,
    x_address2  bytea,
    x_city      bytea,
    x_state     bytea,
    x_postalcode bytea,
    x_country   bytea,
    x_phone     bytea,
    
    alerttype     int,
    x_alertphone  bytea,
    x_alertemail  bytea,

    status      int         not null   default 0,
    pwstatus    int         not null   default 0,
    userlevel   int         not null   default 4,
    tooltips    int         not null   default 1,
    isadmin     int         not null   default 0,
    logincount  int         not null   default 0,
    created     timestamp   not null   default now(),
    updated     timestamp   not null   default now()
);
alter table Members owner to pgsql;
