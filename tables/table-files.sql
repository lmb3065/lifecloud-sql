
-- -----------------------------------------------------------------------------
--  FILES                                                                 Table
-- -----------------------------------------------------------------------------
-- 2013-10-29 dbrown: created
-- 2013-10-30 dbrown: new encrypted Name and Description fields
-- 2013-11-01 dbrown: changed fid to folder_uid
-- -----------------------------------------------------------------------------

create table Files
(
    uid         serial      not null primary key,
    folder_uid  int         not null references Folders(uid),
    mid         int         not null references Members,
    x_name      bytea       not null,
    x_desc      bytea       not null,
    created     timestamp   not null default now()
);
alter table Files owner to pgsql;

