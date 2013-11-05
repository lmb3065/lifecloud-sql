
-- ==============================================================================================
--  DEFAULT_FOLDERS                                                    Table
-- ----------------------------------------------------------------------------------------------
--  reference table of initial folders to be added on account creation
-- 2013-10-165 dbrown: removed column [itemtype]
-- ----------------------------------------------------------------------------------------------

create table ref_defaultfolders
(
    x_name      bytea       not null,
    x_desc      bytea       not null,
    itemtype    int         not null
);
alter table ref_defaultfolders owner to pgsql;

