
-- ==============================================================================================
--  PROFILEPICS
-- ----------------------------------------------------------------------------------------------
--  2013-10-15 dbrown: Created
-- ----------------------------------------------------------------------------------------------

create table profilepics
(
    ppid        serial          not null    primary key,
    mid         int             not null    references Members,
    cid         int             not null    references Accounts,
    path        varchar(128)    not null,
    isprimary   int             not null,
    uploaded    timestamp       not null
);
alter table profilepics owner to pgsql;

