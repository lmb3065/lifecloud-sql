-- LIST BY COMPLEXITY

select proname, pronargs from pg_proc
	where pronamespace = 2200
			-- Ignore pgcrypt library functions
			and (proname not like '%crypt%' 
			and proname not in ('digest','salt','gen_salt','hmac','sha1'))
	order by pronargs desc;
