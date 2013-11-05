
-- ======================================================================
-- function validate_session
--     sessionID varchar(32)
-- ----------------------------------------------------------------------
-- returns: 1 = valid, 0 = invalid
-- ======================================================================

create or replace function validate_session( _tag varchar(32) )
    returns int as $$

begin
    -- To have a valid open session, we must find a row containing the SessionID
    -- and in which the logout time is NULL.  (The logout time is set when
    -- the user logs out explicitly, or is logged out implicitly by logging
    -- in elsewhere.)
    
    if exists ( select * from sessions
            where tag = _tag        -- this is our session 
            and dtlogout is null )  -- and is still open
    then return 1;
    else return 0;
    end if;

end
$$ language plpgsql;
 
 
