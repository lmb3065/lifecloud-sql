
-- ==============================================================================================
--  ACCOUNTS                                                                               Table
-- ----------------------------------------------------------------------------------------------
--  An Account is a Group of Members
-- ----------------------------------------------------------------------------------------------
-- status: 
--   0 = Normal
--   1 = Suspended
--   2 = Closed
--   3 or 9 = Pending signup
-- alertCalendar: Indicates which calendar to use for reminders/alerts
--   0 = uses internal LifeCloud calendar
--   1 = uses external Google calendar
--   2 = uses external Yahoo! calendar
-- ----------------------------------------------------------------------------------------------
-- 2013-09-25 dbrown Encrypted fields moved to Members; owner_mid added; removed autorenew
-- 2013-10-02 dbrown added "referrer"
-- 2013-11-13 dbrown removed redundant (interfering?) NOT NULLs
-- 2014-01-03 dbrown Updated "status" documentation
-- 2014-04-08 dbrown added alertCalendar
-- 2014-05-02 dbrown set alertCalendar default 0
-- 2016-01-27 dbrown Add column payment_type
-- 2017-07-21 dbrown Default Expires column to NULL (open subscription)
-- ----------------------------------------------------------------------------------------------

create table Accounts
(
    cid           serial      primary key, -- Customer ID
    owner_mid     integer     not null,
    status        int         not null,
    quota         bigint      not null,
    referrer      varchar(64),
    alertCalendar int         not null default 0,
    payment_type  varchar(16),
    created       timestamp   default now(),
    updated       timestamp   default now(),
    expires       timestamp   default null
);
alter table Accounts owner to pgsql;

-- LAST CHANGE:
-- 
-- alter table Accounts add column payment_type varchar(16);
