
-- ==============================================================================================
-- function get_account
-- ----------------------------------------------------------------------------------------------
-- 2013-10-16 dbrown: added column member_count; made e-mail case insensitive
-- 2013-10-16 dbrown: simplified to a single main query
-- 2013-11-01 dbrown: revised event code, add error logging
-- 2013-11-11 dbrown: emphasized SQL, uses RAISE for (dev) error
-- ----------------------------------------------------------------------------------------------

create or replace function get_account(

    _cid    int          default null, -- you may search by either of these
    _email  varchar(64)  default null  -- fields, leave the other NULL
    
) returns account_ext_t as $$ -- see /types/account_ext_t.pgsql

declare
    nmembers int;
    fcid int;
    r account_ext_t;
    
begin
    _email := lower(_email);
    
    if _cid is not null then
         -- Accept argument CID
        fcid = _cid;

    elsif _email is not null then
        -- find CID using E-mail
                
        SELECT cid INTO fcid FROM members
        WHERE lower(fdecrypt(x_email)) = _email
            and userlevel = 0;
            
    else
        raise 'get_account() : no search criteria';
        
    end if;
    
    -- Count members and return output --
    
    SELECT count(*) INTO nmembers FROM Members WHERE cid = fcid;
 
    SELECT a.cid, a.status, a.quota, a.referrer, a.created, a.updated,
            a.expires, nmembers, m.mid,
            fdecrypt(x_userid), fdecrypt(x_email), fdecrypt(x_fname), 
            fdecrypt(x_mi), fdecrypt(x_lname), fdecrypt(x_address1), 
            fdecrypt(x_address2), fdecrypt(x_city), fdecrypt(x_state), 
            fdecrypt(x_postalcode), fdecrypt(x_country), fdecrypt(x_phone), 
            m.status, m.pwstatus, m.userlevel, m.tooltips, m.isadmin,
            m.logincount, m.created, m.updated 
        INTO r FROM Accounts a JOIN Members m ON (a.owner_mid = m.mid)
        WHERE a.cid = fcid;
                    
    return r;
    
end
$$ language plpgsql;

