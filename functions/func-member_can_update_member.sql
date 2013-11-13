
--===============================================================================================
-- member_can_update_member()
-- ----------------------------------------------------------------------------------------------
--  Is member source_mid allowed to make a change to member target_mid?  If not, why not?
--  Returns a general answer, and the Members' permissions data in case you have sp criteria. 
--  Designed to exit as soon as possible and do as few queries as necessary.
-------------------------------------------------------------------------------------------------
--  Column 1 ("allowed"):
--   1: Yes, this is allowed (according to default rules)
--   0: No, a required argument was NULL
--  -11: No, source Member could not be found
--  -12: No, target Member could not be found
--  -88: No, source Member is not allowed to modify target Member 
-- The rest of the columns are their permissions fields pulled from Members.
-------------------------------------------------------------------------------------------------
-- 2013-10-13 dbrown: Created
-- 2013-10-24 dbrown: Userlever 2 can now change themselves
-- 2013-11-06 dbrown: All new return values; replaced magic numbers with constants;
--               Removed special case "if target is owner, source can be only self or admin"
-- 2013-11-12 dbrown: Ensure test types and orders conform to documentation; New logic
-------------------------------------------------------------------------------------------------

create or replace function member_can_update_member(

    source_mid      integer,
    target_mid      integer

) returns table (

    allowed int,    -- General "return value" as above
    scid int,       -- Accounts.CID of the "source" Member, the user attempting to make a change 
    slevel int,     -- Members.UserLevel of the source Member
    sisadmin int,
    tcid int,
    tlevel int,
    tisadmin int
    
) as $$

declare
    RETVAL_SUCCESS             constant int := 1;
    RETVAL_ERR_ARG_MISSING     constant int := 0;
    RETVAL_ERR_MEMBER_NOTFOUND constant int := -11;
    RETVAL_ERR_TARGET_NOTFOUND constant int := -12;
    RETVAL_ERR_NOT_ALLOWED     constant int := -88;

    ULEVEL_OWNER    constant int := 0; -- Can modify all Account members
    ULEVEL_TRUSTED  constant int := 1; -- Can modify all Account members except Owner
    ULEVEL_USER     constant int := 2; -- Can modify only themselves
    ULEVEL_VIEWER   constant int := 3; -- Can modify nothing
    
    nil      constant int = null;
    source_cid     int = null;
    source_ulevel  int = null;
    source_isadmin int = null;
    
    target_cid      int = null;
    target_ulevel   int = null;
    target_isadmin  int = null;

begin

    if (source_mid is null) or (target_mid is null) then 
        return query
            SELECT RETVAL_ERR_ARG_MISSING, nil, nil, nil, nil, nil, nil;
        return;
    end if;
    
        
    --=============================================================================
    -- Grab the SOURCE MEMBER from the database
    
    SELECT cid, userlevel, isadmin
        INTO source_cid, source_ulevel, source_isadmin
        FROM Members WHERE mid = source_mid;

    -- Check for: [User-Member] doesn't exist -> NO
    if (source_cid is null) then
        return query SELECT RETVAL_ERR_MEMBER_NOTFOUND, nil, nil, nil, nil, nil, nil;
        return;
    end if;

    -- Changing self?
    if (source_mid = target_mid) then
        if (source_ulevel >= ULEVEL_VIEWER) then
            -- Viewers (and beyond) are not allowed that
            return query SELECT RETVAL_ERR_NOT_ALLOWED, nil, nil, nil, nil, nil, nil;
            return;
        else -- Everyone else is OK
            return query SELECT RETVAL_SUCCESS,
                source_cid, source_ulevel, source_isadmin,
                source_cid, source_ulevel, source_isadmin;
        end if;
    end if;            
    
    
    -- =============================================================================
    -- Grab the TARGET MEMBER from the database
    
    SELECT cid, userlevel, isadmin
        INTO target_cid, target_ulevel, target_isadmin
        FROM Members
        WHERE mid = target_mid;
       
    -- Check for: [Target-Member] doesn't exist -> NO
    if (target_cid is null) then
        return query select RETVAL_ERR_TARGET_NOTFOUND, nil, nil, nil, nil, nil, nil;
        return;
    end if;
    
    -----------------------------------------------------------------------------
    
    if ( -- Three main conditions will allow the Source to change the Target:
    
        (source_isadmin = 1)                     -- Admins can change anyone.        
             
        or (    (source_ulevel = ULEVEL_OWNER)   -- Owners can change anyone
            and (source_cid = target_cid)        --  in the same Account.
        )
      
        or (    (source_ulevel = ULEVEL_TRUSTED) -- Trusteds can change anyone
            and (source_cid = target_cid)        --  in the same Account
            and (target_ulevel <> ULEVEL_OWNER)  --  except the Owner.
        )
        
    ) then
    
        return query select RETVAL_SUCCESS,
                source_cid, source_ulevel, source_isadmin,
                target_cid, target_ulevel, target_isadmin;

    -----------------------------------------------------------------------------
    
    else -- Not allowed    
        return query select RETVAL_ERR_NOT_ALLOWED, nil, nil, nil, nil, nil, nil;
        
    end if;

end;

$$ language plpgsql;


