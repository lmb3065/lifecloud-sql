
-- --------------------------------------------------------------------------
--  EVENTCODES                                               Reference Table
-- --------------------------------------------------------------------------

create table ref_eventcodes
(
    code        char(4)     not null,
    description varchar     not null
);
alter table ref_eventcodes owner to pgsql;

