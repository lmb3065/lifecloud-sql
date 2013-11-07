
-- =============================================================================
--  function get_members()
-- -----------------------------------------------------------------------------
--   Provide one non-NULL argument. Trailing NULL args may be omitted.
--  If you provide ...
--    mid   : Get ONE member by Members.MID
--    email : Get member(s) by e-mail address 
--    cid   : Get member(s) by Account.CID
--  If you provide more than one criterion, the first one will be used.
-- -----------------------------------------------------------------------------
--  Example Usage:
--  get_members( 1337 )                    gets one member MID=1337
--  get_members( 1337, 'foo@bar', 22 )     gets one member MID=1337
--  get_members( null, 'foo@bar' )         gets one member with email foo@bar
--  get_members( null, null, 22 )          gets all members with CID=22
--  get_members( null, null, null )        no results
-- -----------------------------------------------------------------------------
--  2013-10-31 dbrown : Rewritten to incorporate get_member() and member_t
--  2013-11-01 dbrown : Simplified by removing temporary table
--  2013-11-01 dbrown : Stricter argument processing
--  2013-11-01 dbrown : Revised event codes
-- -----------------------------------------------------------------------------

create or replace function get_members(
    
    arg_mid        int          default null, -- Get one member by Members.MID
    arg_email      varchar(64)  default null, -- Get one member by e-mail address
    arg_cid        int          default null  -- Get N members by Account CID

) returns table ( member member_t ) as $$

declare  
    lower_arg_email text;

begin

    -- Argument processing
    if length(arg_email) = 0 then arg_email := NULL; end if;
    -- ... Make sure we have at least one
    if (arg_mid is null and arg_email is null and arg_cid is null) then
        perform log_event(null, null, '9500', 'get_members(): no search criteria');
        return;
    end if;
    -- ... Enfore one-criterion Precedence
    if (arg_mid is not null) then arg_email := null; arg_cid := null; end if;
    if (arg_email is not null) then arg_cid := null; end if;
               

    lower_arg_email = lower(arg_email);

    return query select mid, cid, 
        fdecrypt(x_fname),    fdecrypt(x_lname),      fdecrypt(x_mi),
        fdecrypt(x_userid),   fdecrypt(x_email),      h_profilepic,
        fdecrypt(x_address1), fdecrypt(x_address2),   fdecrypt(x_city),
        fdecrypt(x_state),    fdecrypt(x_postalcode), fdecrypt(x_country),
        fdecrypt(x_phone),
        status, pwstatus, userlevel, tooltips,
        isadmin, logincount, created, updated
    from Members
    
    -- apply filters        
    where ( (arg_mid is not null)   and (mid = arg_mid) )
       or ( (arg_email is not null) and (fdecrypt(x_email) = lower_arg_email) )
       or ( (arg_cid is not null)   and (cid = arg_cid) )
    
    order by fdecrypt(x_fname);
       
    return;
    
end
$$ language plpgsql;


