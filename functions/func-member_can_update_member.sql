
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
--  -1: No, source Member could not be found
--  -2: No, source Member userLevel > max_userlevel
--  -3: No, target Member could not be found
--  -4: No, source and target Members are in different CIDs *
--  -5: No, target Member is an Account Owner *
--             * = allowed if Source is an Admin but Target is not
--  -6: No, target Member outranks source Member
--  -7 : No ... (Reserved)
--  -8 : No ... (Reserved)
--  -9 : No ... (Reserved)
-- -10 ... : You had permission but something went wrong! (Reserved for caller)
-- 
-- The rest of the columns are their permissions data as pulled from Members.
-------------------------------------------------------------------------------------------------
-- 2013-10-13 dbrown: Created
-- 2013-10-24 dbrown: Userlever 2 can now change themselves
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

    nil      constant int = null;
    source_cid        int = null;
    source_userlevel  int = null;
    source_isadmin    int = null;
    
    target_cid        int = null;
    target_userlevel  int = null;
    target_isadmin    int = null;

begin

    if (source_mid is null) or (target_mid is null) then 
        return query select 0, nil, nil, nil, nil, nil, nil;
        return; end if;
    
        
    ----==== Grab and test the Source member first ====----

    select cid, userlevel, isadmin
        into source_cid, source_userlevel, source_isadmin
        from Members where mid = source_mid;    
    
    if (source_cid is null) then
        -- Exit: Source member could not be found
        return query select -1, nil, nil, nil, nil, nil, nil;
        return; end if; 

    -- Changing themselves? We don't have to query the target.
    -- return YES if level 2+
    if (source_mid = target_mid) then
        if source_userlevel <= 2 then
            return query select 1,
                    source_cid, source_userlevel, source_isadmin,
                    source_cid, source_userlevel, source_isadmin;
            return;
        else
            return query select -2, nil, nil, nil, nil, nil, nil;
        end if;
    end if;        
                
    -- If user is changing themselves, we can return a YES at this point
    if (source_mid = target_mid) and source_userlevel = 2 then 
        return query select 1,
                source_cid, source_userlevel, source_isadmin,
                target_cid, target_userlevel, target_isadmin;
        return; 
    end if;

    -- If the caller forced a NULL for max_userlevel, we won't check it
    if (max_userlevel is not null) and (source_userlevel > max_userlevel) then
    -- Exit: Source member has Insufficient UserLevel
        return query select -2, source_cid, source_userlevel, source_isadmin,
                target_cid, target_userlevel, target_isadmin;
        return; end if;


    
    ----==== Grab and test the Target member ====----
    
    select cid, userlevel, isadmin
        into target_cid, target_userlevel, target_isadmin
        from Members where mid = target_mid;    
            
    if (target_cid is null) then 
        -- Exit: Target member could not be found
        return query select -3,
                source_cid, source_userlevel, source_isadmin, nil, nil, nil;
        return; end if; 
    
    if (target_cid <> source_cid) and (source_isadmin = 0) then
        -- Exit: only Admins can alter Members of different Accounts
        return query select -4,
                source_cid, source_userlevel, source_isadmin,
                target_cid, target_userlevel, target_isadmin;
        return; end if;

    if (target_userlevel = 0) and (source_isadmin = 0) then
        -- Exit: only Admins can alter Account Owners
        return query select -5,
                source_cid, source_userlevel, source_isadmin,
                target_cid, target_userlevel, target_isadmin;
        return; end if;

    if (target_userlevel < source_userlevel)
    or (target_isadmin   > source_isadmin  ) then
         -- Exit: Target outranks Source
        return query select -6,
                source_cid, source_userlevel, source_isadmin,
                target_cid, target_userlevel, target_isadmin;
        return; end if;
   
    
    -- Success
    
    return query select 1,
            source_cid, source_userlevel, source_isadmin,
            target_cid, target_userlevel, target_isadmin;
    return;    
    
end;

$$ language plpgsql;


