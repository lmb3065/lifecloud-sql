
-- -----------------------------------------------------------------------------
--  table reg_codes
-- -----------------------------------------------------------------------------
-- 2014-12-30 dbrown: created
-- 2015-01-07 dbrown: make 'code' column primary key
-- 2015-01-15 dbrown: add column discount (int)
-- 2015-03-23 dbrown: add column paypal_button_id
-- 2015-06-27 dbrown: add columns periodN, amountN
-- 2015-10-14 dbrown: Add 2nd group of Paypal fields
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
    paypal_button_id_1 varchar(16),
    period1_1       char(1),
    period2_1       char(1),
    period3_1       char(1),
    amount1_1       varchar(10),
    amount2_1       varchar(10),
    amount3_1       varchar(10),
    paypal_button_id_2 varchar(16),
    period1_2       char(1),
    period2_2       char(1),
    period3_2       char(1),
    amount1_2       varchar(10),
    amount2_2       varchar(10),
    amount3_2       varchar(10)
);

alter table reg_codes owner to pgsql;

/* Latest change:

    alter table reg_codes rename paypal_button_id   to paypal_button_id_1;
    alter table reg_codes rename period1            to period1_1;
    alter table reg_codes rename period2            to period2_1;
    alter table reg_codes rename period3            to period3_1;
    alter table reg_codes rename amount1            to amount1_1;
    alter table reg_codes rename amount2            to amount2_1;
    alter table reg_codes rename amount3            to amount3_1;
    alter table reg_codes add                          paypal_button_id_2   varchar(16);
    alter table reg_codes add                          period1_2            char(1);
    alter table reg_codes add                          period2_2            char(1);
    alter table reg_codes add                          period3_2            char(1);
    alter table reg_codes add                          amount1_2            varchar(10);
    alter table reg_codes add                          amount2_2            varchar(10);
    alter table reg_codes add                          amount3_2            varchar(10);

*/
