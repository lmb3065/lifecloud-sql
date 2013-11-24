-- ===========================================================================
--  type file_t
-- ---------------------------------------------------------------------------
--  File output type common to get_files and get_forms
-- ---------------------------------------------------------------------------
--  2013-11-23 dbrown: created
-- ---------------------------------------------------------------------------

create type file_t as (

    uid          int,
    fid          int,
    mid          int,
    created      timestamp,
    filename     text,
    description  text,
    content_type varchar,
    isform       int,
    category     int,
    modified_by  int,
    nrows        int,
    npages       int

);

alter type file_t owner to pgsql;
