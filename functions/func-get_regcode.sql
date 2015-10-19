
-- 2015-01-07 dbrown: Created
-- 2015-03-23 dbrown: Add column paypal_button_id
-- 2015-06-27 dbrown: Add columns periodN amountN
--              drop function get_regcode(text);
-- 2015-10-14 dbrown: Add 2nd group of Paypal fields

-- drop function get_regcode(text);
create or replace function get_regcode
(
    _code text
) returns table (
    code              text,
    maximum_uses      int,
    code_uses         int,
    description       text,
    code_effective    timestamp,
    code_expires      timestamp,
    account_expires   timestamp,
    account_life      int,
    discount          int,
    paypal_button_id_1  varchar(16),
    period1_1           varchar(4),
    period2_1           varchar(4),
    period3_1           varchar(4),
    amount1_1           varchar(10),
    amount2_1           varchar(10),
    amount3_1           varchar(10),
    paypal_button_id_2  varchar(16),
    period1_2           varchar(4),
    period2_2           varchar(4),
    period3_2           varchar(4),
    amount1_2           varchar(10),
    amount2_2           varchar(10),
    amount3_2           varchar(10)
) as $$

begin

    return query
        select * from reg_codes
        where reg_codes.code = _code;

end;
$$ language plpgsql;
