
-- ==============================================================================================
-- function get_account
-- ----------------------------------------------------------------------------------------------
-- 2013-10-16 dbrown: added column member_count; made e-mail case insensitive
-- 2013-10-16 dbrown: simplified to a single main query
-- ----------------------------------------------------------------------------------------------

create or replace function get_account(

    _cid    int          default null, -- you may search by either of these
    _email  varchar(64)  default null  -- fields, leave the other NULL
    
) returns account_ext_t as $$ -- see /types/account_ext_t.pgsql

declare
    acct_members int;
    foundcid int;
    r account_ext_t;
    
begin

    -- Get e-mail address if we don't have CID
    
    if _cid is not null then 
        foundcid = _cid; -- Accept argument CID
                
    elsif _email is not null then -- find CID ourselves using E-mail
        select cid into foundcid from members
        where lower(fdecrypt(x_email)) = lower(_email)
            and userlevel = 0;
            
    else return null; -- both arguments were null!
    end if;

    
    -- Count members and return output --
    
    select count(*) into acct_members from Members where cid = foundcid;
 
    select a.cid, a.status, a.quota, a.referrer, a.created, a.updated,
            a.expires, acct_members, m.mid,
            fdecrypt(x_userid), fdecrypt(x_email), fdecrypt(x_fname), 
            fdecrypt(x_mi), fdecrypt(x_lname), fdecrypt(x_address1), 
            fdecrypt(x_address2), fdecrypt(x_city), fdecrypt(x_state), 
            fdecrypt(x_postalcode), fdecrypt(x_country), fdecrypt(x_phone), 
            m.status, m.pwstatus, m.userlevel, m.tooltips, m.isadmin,
            m.logincount, m.created, m.updated 
        into r from Accounts a join Members m on (a.owner_mid = m.mid)
        where a.cid = foundcid;
                    
    return r;
    
end
$$ language plpgsql;

