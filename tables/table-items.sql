-- =========================================================================
--  ITEMS
-- -------------------------------------------------------------------------
--  2013-12-11 dbrown Created
-- -------------------------------------------------------------------------

create table items
(
    uid         serial      not null primary key,
    mid         int         not null references Members(MID),
    cid         int         not null references Accounts(CID),
    folder_uid  int         not null references Folders(UID),
    app_uid     int,        -- optional reference to ref_apps(UID)
    x_name      bytea       not null,
    x_desc      bytea       not null,
    created     timestamp   not null default now(),
    updated     timestamp   not null default now()
);
alter table Items owner to pgsql;
