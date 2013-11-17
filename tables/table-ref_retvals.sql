
 -- -----------------------------------------------------------------------------
 --  REF_RETVALS
 -- -----------------------------------------------------------------------------

create table ref_retvals
(
    retval  int     not null primary key,
    msg     text    not null
);
alter table ref_retvals owner to pgsql;

