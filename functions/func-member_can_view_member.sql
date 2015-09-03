
 -- function member_can_view_member
 --
 -- Is member source_mid allowed to view items belonging to target_mid?  If not, why not?
 -- Returns a general answer, and both Members' permissions data 
 --
 -- Column 1 ("allowed"):
 --   1: Yes, this is allowed (according to default rules)
 --   0: No, a required argument was NULL
 --  -11: No, source Member could not be found
 --  -12: No, target Member could not be found
 --  -88: No, source Member is not allowed to modify target Member
 -- The rest of the columns are their permissions fields pulled from Members.
 --
 -- 2015-09-03 dbrown: Created

create or replace function member_can_view_member(

    source_mid integer,
    target_mid integer

) returns table (

    allowed  int,
    scid     int,
    slevel   int,
    sisadmin int,
    tcid     int,
    tlevel   int,
    tisadmin int

) as $$

declare
    RETVAL_SUCCESS             constant int := 1;
    RETVAL_ERR_ARG_MISSING     constant int := 0;
    RETVAL_ERR_SOURCE_NOTFOUND constant int := -11;
    RETVAL_ERR_TARGET_NOTFOUND constant int := -12;
    RETVAL_ERR_NOT_ALLOWED     constant int := -80;

    ULEVEL_OWNER    constant int := 0; -- Can view all Account members
    ULEVEL_TRUSTED  constant int := 1; -- Can view all Account members
    ULEVEL_USER     constant int := 2; -- Can view self only
    ULEVEL_VIEWER   constant int := 3; -- Can view self only

    source_cid      int = null;
    source_ulevel   int = null;
    source_isadmin  int = null;

    target_cid      int = null;
    target_ulevel   int = null;
    target_isadmin  int = null;

begin

    if (source_mid is null) or (target_mid is null) then
        return query select RETVAL_ERR_ARG_MISSING, null, null, null, null, null, null;
        return;
    end if;

    -- Grab the SOURCE member from the database

    select cid, userlevel, isadmin
        into source_cid, source_ulevel, source_isadmin
        from members where mid = source_mid;

    if (source_cid is null) then
        return query select RETVAL_ERR_SOURCE_NOTFOUND, null, null, null, null, null, null;
        return;
    end if;

    -- Looking at self? OK

    if (source_mid = target_mid) then
        return query select RETVAL_SUCCESS,
            source_cid, source_ulevel, source_isadmin,
            source_cid, source_ulevel, source_isadmin;
        return;
    end if;

    -- Grab the TARGET member from the database

    select cid, userlevel, isadmin
        into target_cid, target_ulevel, target_isadmin
        from members where mid = target_mid;

    if (target_cid is null) then
        return query select RETVAL_ERR_TARGET_NOTFOUND, null, null, null, null, null, null;
        return;
    end if;

    -----------------------------------------------------------------------------
    -- Permissions for members who can viuew other members -- who can they see?

    if (
            (source_isadmin = 1)            -- Admins can view anyone.
      or (
            (source_ulevel = ULEVEL_OWNER)  -- Owners can view anyone
        and (source_cid = target_cid)       -- in the same account.
      ) or (
            (source_ulevel = ULEVEL_OWNER)  -- Trusteds can view anyone
        and (source_cid = target_cid)       -- in the same account.
      )

    ) then

        return query select RETVAL_SUCCESS,
            source_cid, source_ulevel, source_isadmin,
            target_cid, target_ulevel, target_isadmin;

    else
        return query select RETVAL_ERR_NOT_ALLOWED,
            source_cid, source_ulevel, source_isadmin,
            target_cid, target_ulevel, target_isadmin;
    end if;

end;

$$ language plpgsql;

