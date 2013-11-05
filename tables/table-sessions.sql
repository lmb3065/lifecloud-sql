
-- -----------------------------------------------------------------------------
--  SESSIONS
--  x_ columns contains PGP-encrypted string data
-- -----------------------------------------------------------------------------
-- 2009-09-25 dbrown : Members.UID renamed to Members.MID
-- 2013-10-15 dbrown : all columns except dtlogout made NOT NULL
--------------------------------------------------------------------------------

create table Sessions
(
    sid         serial      not null  primary key,
    mid         integer     not null  references Members,
    tag         varchar(32) not null,
    x_ipaddr    bytea       not null,
    dtlogin     timestamp   not null  default clock_timestamp(),
    dtlogout    timestamp   default null
);
alter table Sessions owner to pgsql;

