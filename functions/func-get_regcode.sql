
-- 2015-01-07 dbrown: Created

create or replace function get_regcode
(
    _code text
) returns table (
    code            text,
    maximum_uses    int,
    code_uses       int,
    description     text,
    code_effective  timestamp,
    code_expires    timestamp,
    account_expires timestamp,
    account_life    int    
) as $$

begin

    return query
        select * from reg_codes
        where reg_codes.code = _code;

end;
$$ language plpgsql;
