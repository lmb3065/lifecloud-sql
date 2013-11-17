
-- -----------------------------------------------------------------------------
--  FILES                                                                 Table
-- -----------------------------------------------------------------------------
-- 2013-10-29 dbrown: created
-- 2013-10-30 dbrown: new encrypted Name and Description fields
-- 2013-11-01 dbrown: changed fid to folder_uid
-- 2013-11-06 dbrown: added column modified_by
-- 2013-11-16 dbrown: added column content_type
-- -----------------------------------------------------------------------------

create table Files
(
    uid          serial      not null primary key,
    folder_uid   int         not null references Folders,
    mid          int         not null references Members,
    x_name       bytea       not null,
    x_desc       bytea       not null,
    content_type varchar,
    modified_by  int,              -- references Members
    created      timestamp   not null default now()
);
alter table Files owner to pgsql;
