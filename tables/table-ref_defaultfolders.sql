
-- ==============================================================================================
--  DEFAULT_FOLDERS                                                    Table
-- ----------------------------------------------------------------------------------------------
--  reference table of initial folders to be added on account creation
-- ----------------------------------------------------------------------------------------------

create table ref_defaultfolders
(
    x_name      bytea       not null,
    x_desc      bytea       not null
);
alter table ref_defaultfolders owner to pgsql;

