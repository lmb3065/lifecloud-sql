
-- 2015-01-07 dbrown: Created
-- 2015-03-23 dbrown: Add column paypal_button_id
-- 2015-06-27 dbrown: Add columns periodN amountN
--              drop function get_regcode(text);

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
    paypal_button_id  varchar(16),
    period1           char(1),
    period2           char(1),
    period3           char(1),
    amount1           varchar(10),
    amount2           varchar(10),
    amount3           varchar(10)
) as $$

begin

    return query
        select * from reg_codes
        where reg_codes.code = _code;

end;
$$ language plpgsql;
