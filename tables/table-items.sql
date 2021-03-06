-- =========================================================================
--  ITEMS
-- -------------------------------------------------------------------------
--   An Item is a group of Files with a name and description.
--   files.item_uid points to items.uid.
-- -------------------------------------------------------------------------
--  2013-12-11 dbrown Created
--  2013-12-17 dbrown Added column modified_by
--  2014-10-02 dbrown Added column itemtype
--              alter table Items add column itemtype int not null default 1
-- -------------------------------------------------------------------------

create table items
(
    uid         serial      not null primary key,
    mid         int         not null references Members(MID),
    cid         int         not null references Accounts(CID),
    folder_uid  int         not null references Folders(UID),
    app_uid     int,        -- optional reference to ref_apps(UID)
    itemtype    int         not null default 1,  -- reference to ref_itemtypes(UID)
    x_name      bytea       not null,
    x_desc      bytea       not null,
    created     timestamp   not null default now(),
    updated     timestamp   not null default now(),
    modified_by int         -- optional reference to members(MID)
);
alter table Items owner to pgsql;
