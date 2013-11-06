
-- -----------------------------------------------------------------------------
--  table ref_apps
-- -----------------------------------------------------------------------------
-- 2013-11-05 dbrown: created
-- -----------------------------------------------------------------------------

create table ref_apps
(
    uid         serial  not null  primary key,
    app_url     text    not null,
    app_name    text    not null,
    app_icon    text    not null
);
alter table ref_apps owner to pgsql;

