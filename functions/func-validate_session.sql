
-- ======================================================================
-- function validate_session
--     sessionID varchar(32)
-- ----------------------------------------------------------------------
-- returns: 1 = OK, found an open session
--          0 = Not OK: found a session, but it was closed
--         -1 = Not OK: there is no session with that tag
-- -----------------------------------------------------------------------------
-- 2013-11-15 dbrown: Now returns 0 if session closed, -1 if nonexistent 
-- ======================================================================

create or replace function validate_session( _tag varchar(32) )
    returns int as $$

declare
    RETVAL_SUCCESS constant int := 1;

    _sid      int;
    _dtlogout timestamp;
    
begin
    -- To have a valid open session, we must find a row containing the SessionID
    -- and in which the logout time is NULL.  (The logout time is set when
    -- the user logs out explicitly, or is logged out implicitly by logging
    -- in elsewhere.)
    
    select sid, dtlogout into _sid, _dtlogout
        from sessions
        where tag = _tag;

    if    (_sid is null)          then return -1;  -- No such Session      (X)
    elsif (_dtlogout is not null) then return  0;  -- Found closed Session (X)
    else return RETVAL_SUCCESS;                    -- Found Open Session   (OK)
    end if;

end
$$ language plpgsql;
 
 
