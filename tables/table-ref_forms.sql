-- ===========================================================================
--  table ref_forms
-- ---------------------------------------------------------------------------
--  Reference table indexing the PDF forms
-- ---------------------------------------------------------------------------
--  2013-11-21 dbrown: created
--  2013-11-22 dbrown: added column Category
-- ---------------------------------------------------------------------------

create table ref_forms
(
    title    text    not null,
    category text    not null,
    filename text    not null
);
alter table ref_forms owner to pgsql;
