
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
-- ----------------------------------------------------------------------------------------------

create table Accounts
(
    cid           serial      primary key, -- Customer ID
    owner_mid     integer     not null,
    status        int         not null,
    quota         bigint      not null,
    referrer      varchar(64),
    alertCalendar int         not null default 0,
    created       timestamp   default now(),
    updated       timestamp   default now(),
    expires       timestamp   default current_date + interval '1 year'
);
alter table Accounts owner to pgsql;

