-- --------------------------------------------------------------------------
--  FOLDERS                                                            Table
-- --------------------------------------------------------------------------
-- 2013-09-25 dbrown : renamed UID to FID
-- 2013-10-09 dbrown : replaced cid with MID
-- 2013-10-10 dbrown : instead of NULL, root folders have parentfid of -1
-- 2013-10-11 dbrown : removed 'parentfid'
-- 2013-10-15 dbrown : removed 'vieworder' and 'complete'; all NOT NULL
-- 2013-10-29 dbrown : removed column 'deleted'
-- 2013-11-01 dbrown : renamed FID to UID
-- 2013-12-11 dbrown : renamed & repurposed itemtype to app_uid
-- --------------------------------------------------------------------------

create table Folders
(
    uid         serial      not null primary key,
    mid         int         not null references Members,
    cid         int         not null references Accounts,
    x_name      bytea       not null,
    x_desc      bytea       not null,
    app_uid     int,        -- optional reference to ref_apps.uid
    created     timestamp   not null default now(),
    updated     timestamp   not null default now()
);
alter table folders owner to pgsql;
