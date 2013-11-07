
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
--  -80: No, source Member userLevel > max_userlevel
--  -81: No, source and target Members are in different CIDs *
--  -82: No, target Member outranks source Member
-- The rest of the columns are their permissions fields pulled from Members.
-------------------------------------------------------------------------------------------------
-- 2013-10-13 dbrown: Created
-- 2013-10-24 dbrown: Userlever 2 can now change themselves
-- 2013-11-06 dbrown: All new return values; replaced magic numbers with constants;
--       Removed special case "if target is account owner, source can be only self or admin" 
-------------------------------------------------------------------------------------------------

create or replace function member_can_update_member(

    source_mid      integer,
    target_mid      integer,
    max_userlevel   integer default 1

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
    RETVAL_ERR_USERLEVEL       constant int := -80;
    RETVAL_ERR_DIFFACCOUNTS    constant int := -81;
    RETVAL_ERR_OUTRANKED       constant int := -82;

    nil      constant int = null;
    source_cid        int = null;
    source_userlevel  int = null;
    source_isadmin    int = null;
    
    target_cid        int = null;
    target_userlevel  int = null;
    target_isadmin    int = null;

begin

    if (source_mid is null) or (target_mid is null) then 
        return query select RETVAL_ERR_ARG_MISSING, nil, nil, nil, nil, nil, nil;
        return; end if;
    
        
    ----==== Grab and test the Source member first ====----

    select cid, userlevel, isadmin
        into source_cid, source_userlevel, source_isadmin
        from Members where mid = source_mid;    
    
    if (source_cid is null) then
        return query select RETVAL_ERR_MEMBER_NOTFOUND, nil, nil, nil, nil, nil, nil;
        return; end if; 

    -- Changing themselves? Return YES if userlevel in ( 0,1,2 )
    if (source_mid = target_mid) then
        if source_userlevel <= 2 then
            return query select RETVAL_SUCCESS,
                    source_cid, source_userlevel, source_isadmin,
                    source_cid, source_userlevel, source_isadmin;
            return;
        else
            return query select RETVAL_ERR_USERLEVEL,
                    source_cid, source_userlevel, source_isadmin,
                    nil, nil, nil;
        end if;
    end if;        

    -- If the caller forced a NULL for max_userlevel, we won't check it
    if (max_userlevel is not null) and (source_userlevel > max_userlevel) then
        -- Exit: Source member has Insufficient UserLevel
        return query select RETVAL_ERR_USERLEVEL,
                    source_cid, source_userlevel, source_isadmin,
                    nil, nil, nil;
        return; end if;


    
    ----==== Grab and test the Target member ====----
    
    select cid, userlevel, isadmin
        into target_cid, target_userlevel, target_isadmin
        from Members where mid = target_mid;    
            
    if (target_cid is null) then 
        -- Exit: Target member could not be found
        return query select RETVAL_ERR_TARGET_NOTFOUND,
                source_cid, source_userlevel, source_isadmin, nil, nil, nil;
        return; end if; 

        
        
    ----==== Test the relation between the two ====----
        
    if (source_cid <> target_cid) and (source_isadmin = 0) then
        -- Exit: only Admins can alter Members of different Accounts
        return query select RETVAL_ERR_DIFFACCOUNTS,
                source_cid, source_userlevel, source_isadmin,
                target_cid, target_userlevel, target_isadmin;
        return; end if;    

    if ((source_isadmin < target_isadmin)
     or (source_userlevel > target_userlevel)) then
         -- Exit: Target outranks Source
        return query select RETVAL_ERR_OUTRANKED,
                source_cid, source_userlevel, source_isadmin,
                target_cid, target_userlevel, target_isadmin;
        return;
        
    end if;
   
    
    -- If you got this far then yes, sourceMember can update targetMember
    
    return query select RETVAL_SUCCESS,
            source_cid, source_userlevel, source_isadmin,
            target_cid, target_userlevel, target_isadmin;
    return;    
    
end;

$$ language plpgsql;


