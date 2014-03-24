create or replace function _test_add_account( _ntests int ) returns setof int as
$$
declare
    result int; i int;
    date_perturb int;
begin

    if (_ntests < 1) then return; end if;

    for i in 1.._ntests loop

        date_perturb := (floor( random()*10)-5)::int;

        result = add_account(
            _test_mkstr(16),           -- email
            '12345',                   -- passwd
            _test_mkstr(8),            -- lname
            _test_mkstr(8),            -- fname
            _test_mkstr(1,   0.5),     -- mi
            current_date + date_perturb, -- expires
            _test_mkstr(64,  0.5),     -- referrer
            _test_mkstr(32,  0.5),     -- address1
            _test_mkstr(32,  0.5),     -- address2
            _test_mkstr(16,  0.5),     -- city
            _test_mkstr( 2,  0.5),     -- state
            _test_mkstr(16,  0.5),     -- postalcode
            _test_mkstr( 2,  0.5),     -- country
            _test_mkstr(20,  0.5),     -- phone
            round(random())::int       -- status
        );

        return next result;

    end loop;

end;
$$
language plpgsql;
