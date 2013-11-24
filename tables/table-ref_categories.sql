-- ===========================================================================
--  table ref_categories
-- ---------------------------------------------------------------------------
--  2013-11-23 dbrown: created
-- ---------------------------------------------------------------------------

create table ref_categories
(
    uid         serial primary key,
    name        text not null
);
alter table ref_categories owner to pgsql;
