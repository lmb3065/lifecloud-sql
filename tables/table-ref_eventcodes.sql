
-- --------------------------------------------------------------------------
--  EVENTCODES                                               Reference Table
-- --------------------------------------------------------------------------
-- 2013-11-14 dbrown: made code primary key to prevent dups

create table ref_eventcodes
(
    code        char(4)     not null primary key,
    description varchar     not null
);
alter table ref_eventcodes owner to pgsql;

