-- ===========================================================================
--  table ref_forms
-- ---------------------------------------------------------------------------
--  Reference table indexing the PDF forms
--   * DEPENDS ON ref_categories !
-- ---------------------------------------------------------------------------
--  2013-11-21 dbrown: created
--  2013-11-22 dbrown: added column Category
-- ---------------------------------------------------------------------------

create table ref_forms
(
    title        text    not null,
    filename     text    not null,
    category     int     not null   ----> categories.uid
);
alter table ref_forms owner to pgsql;
