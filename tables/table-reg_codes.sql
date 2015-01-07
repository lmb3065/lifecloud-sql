
-- -----------------------------------------------------------------------------
--  table reg_codes
-- -----------------------------------------------------------------------------
-- 2014-12-30 dbrown: created
-- 2015-01-07 dbrown: make 'code' column primary key
-- -----------------------------------------------------------------------------

create table reg_codes
(
    code            text    not null  primary key,
    maximum_uses    int     not null,
    code_uses       int     not null  default 0,
    description     text,
    code_effective  timestamp not null,
    code_expires    timestamp,
    account_expires timestamp,
    account_life    int
);
alter table reg_codes owner to pgsql;
