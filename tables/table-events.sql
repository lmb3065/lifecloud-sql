
-- --------------------------------------------------------------------------
--  EVENTS                                                             Table
-- --------------------------------------------------------------------------

create table events
(
    eid serial primary key,
    cid         integer,     --  references accounts,
    mid         integer,     --  references members,
    target_cid  integer,
    target_mid  integer,
    dt          timestamp   default clock_timestamp(),
    code        char(4)     not null,
    x_data      bytea
);
alter table events owner to pgsql;
create index on events (dt);

