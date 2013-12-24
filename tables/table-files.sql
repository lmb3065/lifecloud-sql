-- -----------------------------------------------------------------------------
--  FILES                                                                 Table
-- -----------------------------------------------------------------------------
-- 2013-10-29 dbrown: created
-- 2013-10-30 dbrown: new encrypted Name and Description fields
-- 2013-11-01 dbrown: changed fid to folder_uid
-- 2013-11-06 dbrown: added column modified_by
-- 2013-11-16 dbrown: added column content_type
-- 2013-11-23 dbrown: added columns isForm, category
-- 2013-12-11 dbrown: added item_uid
-- 2013-12-20 dbrown: added updated
-- 2013-12-24 dbrown: added form_data, changed isform to isprofile
-- -----------------------------------------------------------------------------

create table Files
(
    uid          serial      not null primary key,
    folder_uid   int         not null references Folders,
    mid          int         not null references Members,
    item_uid     int,        -- optional reference to Items(UID),
    x_name       bytea       not null,
    x_desc       bytea       not null,
    content_type varchar,
    isprofile    int         default 0,
    category     int,           -- reference to ref_Categories(UID)
                                -- Only meaningful if isProfile=1
    x_form_data  bytea,         -- Only meaningful if isProfile=1
    modified_by  int,           -- reference to Members(MID)
    created      timestamp   not null default now(),
    updated      timestamp   not null default now()
);
alter table Files owner to pgsql;
