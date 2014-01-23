create or replace function _test_add_folder( _ntests int ) returns setof int as
$$
declare
    result int; i int;
    nmids int; mid1 int; mid2 int;
    roffset int;
begin
    if (_ntests < 1) then return; end if;

    select count(mid) into nmids from members;

    for i in 1.._ntests loop

        roffset := (floor(random()*nmids))::int;
        select mid into mid1 from members offset roffset limit 1;
        roffset := (floor(random()*nmids))::int;
        select mid into mid2 from members offset roffset limit 1;

        result = add_folder(mid1, mid2,
            _test_mkstr(4,   0.01),
            _test_mkstr(128, 0.1),
            null, 1 );

        return next result;

    end loop;

end;
$$
language plpgsql;
