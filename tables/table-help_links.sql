
-- ---------------------------------------------------------------------------
-- HELP LINKS
-- ---------------------------------------------------------------------------
-- 2016-08-04 dbrown: created
-- ---------------------------------------------------------------------------

create table help_links
(
    code        integer     not null,
    doc_link    text,
    vid_link    text
);
alter table help_links owner to pgsql;
