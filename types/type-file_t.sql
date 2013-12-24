-- ===========================================================================
--  type file_t
-- ---------------------------------------------------------------------------
--  File output type common to get_files and get_forms
-- ---------------------------------------------------------------------------
--  2013-11-23 dbrown: created
--  2013-12-12 dbrown: added item_uid
--  2013-12-20 dbrown: added updated
-- ---------------------------------------------------------------------------

create type file_t as (

    uid          int,
    fid          int,
    mid          int,
    item_uid     int,
    created      timestamp,
    filename     text,
    description  text,
    content_type varchar,
    isprofile    int,
    category     int,
    form_data    text,
    modified_by  int,
    updated      timestamp,
    nrows        int,
    npages       int

);

alter type file_t owner to pgsql;
