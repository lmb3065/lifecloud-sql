
-- -----------------------------------------------------------------------------
--  table reg_codes
-- -----------------------------------------------------------------------------
-- 2014-12-30 dbrown: created
-- 2015-01-07 dbrown: make 'code' column primary key
-- 2015-01-15 dbrown: add column discount (int)
-- 2015-03-23 dbrown: add column paypal_button_id
-- 2015-06-27 dbrown: add columns periodN, amountN
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
    paypal_button_id varchar(16),
    period1         char(1),
    period2         char(1),
    period3         char(1),
    amount1         varchar(10),
    amount2         varchar(10),
    amount3         varchar(10)
);
alter table reg_codes owner to pgsql;

/* Latest change:

    alter table reg_codes
        add period1 varchar(4),
        add period2 varchar(4),
        add period3 varchar(4),
        add amount1 varchar(10),
        add amount2 varchar(10),
        add amount3 varchar(10); 

*/
