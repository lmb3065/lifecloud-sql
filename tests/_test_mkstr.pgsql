create or replace function _test_mkstr(
    _length int,
    _nullchance numeric default null
) returns text as
$$
declare
    C_LOWER constant text := 'abcdefghijklmnopqrstuvwxyz';
    C_UPPER constant text := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    C_DIGIT constant text := '0123456789';

    i int;
    buf text := '';
    n int;

begin

    if (_length < 1) then return null; end if;

    if (_nullchance) is not null then
        -- Corrupt output with NULLs
        if (random() <= _nullchance) then return null; end if;
    end if;

    for i in 1.._length loop
        n = floor( random() * 52 )::int;
        buf := buf || substring( C_LOWER||C_UPPER from n for 1);
    end loop;

    return buf;

end;
$$
language plpgsql;