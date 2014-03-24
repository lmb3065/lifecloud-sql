create or replace function _test_add_member( _ntests int ) returns setof int as
$$
declare
    C_MAXLOGINS constant int := 10;

    result int; i int;
    parentcid int;
    ncids int;

    random_offset int;
    new_cid int;

begin

    if (_ntests < 1) then return; end if;

    select count(cid) into ncids from accounts;

    for i in 1.._ntests loop

        -- Pick a random account
        random_offset := (floor(random()*ncids))::int;
        select cid into new_cid from accounts offset random_offset limit 1;

        result = add_member(
            new_cid,
            _test_mkstr(8),         -- fname
            _test_mkstr(8),         -- lname
            _test_mkstr(1, 1/4),   -- mi
            '12345',                -- pw
            _test_mkstr(16, 1/4),  -- userid
            _test_mkstr(16, 1/4),  -- email
            null,                  -- profilepic hash
            _test_mkstr(32, 1/4),  -- address1
            _test_mkstr(32, 1/4),  -- address2
            _test_mkstr(16, 1/4),  -- city
            _test_mkstr( 2, 1/4),  -- state
            _test_mkstr( 5, 1/4),-- postalcode
            _test_mkstr( 2, 1/4), -- country
            _test_mkstr(20, 1/4), -- phone
            C_MAXLOGINS,                -- maxlogins
            floor(random()*(4))::int, -- status 0-3
            round(random())::int,       -- pwstatus 0-1
            floor(random()*(4))::int, -- userlevel 0-3
            round(random())::int        -- tooltips 0-1
        );

        return next result;

    end loop;

end;
$$
language plpgsql;
