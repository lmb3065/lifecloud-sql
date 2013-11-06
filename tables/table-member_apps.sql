
-- -----------------------------------------------------------------------------
--  table member_apps
-- -----------------------------------------------------------------------------
-- 2013-11-05 dbrown: Created

create table member_apps
(
    mid     integer primary key references members,
    apps    char(64) not null
);
alter table events owner to pgsql;


