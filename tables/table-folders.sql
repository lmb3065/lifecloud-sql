
-- --------------------------------------------------------------------------
--  FOLDERS                                                            Table
-- --------------------------------------------------------------------------
-- 2013-09-25 dbrown : renamed UID to FID
-- 2013-10-09 dbrown : replaced cid with MID
-- 2013-10-10 dbrown : instead of NULL, root folders have parentfid of -1
-- 2013-10-11 dbrown : removed 'parentfid'
-- 2013-10-15 dbrown : removed 'vieworder' and 'complete'; all NOT NULL
-- 2013-10-29 dbrown : removed column 'deleted'
-- --------------------------------------------------------------------------

create table Folders
(
    fid         serial      not null primary key,
    mid         int         not null references Members,
    cid         int         not null references Accounts,
    x_name      bytea       not null,
    x_desc      bytea       not null,
    itemtype    int         not null,
    created     timestamp   not null default now(),
    updated     timestamp   not null default now()
);
alter table folders owner to pgsql;

