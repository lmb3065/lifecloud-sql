-- ======================================================================
-- get_mailpw
--     arg_un text : Decrypted user name
-- ----------------------------------------------------------------------
-- example:
--     select pw from get_mailpw('%u@%r');
-- ----------------------------------------------------------------------
-- Returns mail user's password in cleartext
-- ----------------------------------------------------------------------
-- 2015-12-18 lbrown : Function created
-- ----------------------------------------------------------------------
create or replace function get_mailpw(

    arg_un varchar(64)

) returns table(pw text) as $$

declare
	_un_c  varchar(64) := lower(arg_un);
	_pw_c  varchar(64);

begin

	return query
		select fdecrypt(x_pw) as pw 
		from mailusers
		where lower(fdecrypt(x_un)) = _un_c;
		
end;
$$ language plpgsql;


