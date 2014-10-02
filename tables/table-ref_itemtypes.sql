-- ===========================================================================
--  table ref_itemtypes
-- ---------------------------------------------------------------------------
--  2014-10-02 dbrown: Created
-- ---------------------------------------------------------------------------

create table ref_itemtypes
(
    uid         serial primary key,
    name        text not null
);
alter table ref_itemtypes owner to pgsql;
