
-- -----------------------------------------------------------------------------
--  table reg_codes
-- -----------------------------------------------------------------------------
-- 2014-12-30 dbrown: created
-- 2015-01-07 dbrown: make 'code' column primary key
-- 2015-01-15 dbrown: add column discount (int)
-- 2015-03-23 dbrown: add column paypal_button_id
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
    account_life    int,
    discount        int,
    paypal_button_id varchar(16)
);
alter table reg_codes owner to pgsql;
