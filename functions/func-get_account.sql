
-- ==============================================================================================
-- function get_account
-- ----------------------------------------------------------------------------------------------
-- only returns ONE account
-- 2013-10-16 dbrown: added column member_count; made e-mail case insensitive
-- 2013-10-16 dbrown: simplified to a single main query
-- 2013-11-01 dbrown: revised event code, add error logging
-- 2013-11-11 dbrown: emphasized SQL, raises warning on missing args
-- 2013-11-14 dbrown: organization, constants, more info in event logs
-- 2016-01-29 dbrown: Add field payment_type
-- ----------------------------------------------------------------------------------------------

create or replace function get_account(

    _cid    int          default 0, -- you may search by either of these
    _email  varchar(64)  default ''  -- fields, leave the other NULL

) returns account_ext_t as $$

declare
    EVENT_USERERR_GETTING_ACCOUNT   constant char(4) := '4026';
    EVENT_DEVERR_GETTING_ACCOUNT    constant char(4) := '9026';
    USERLEVEL_OWNER constant int = 0;

    nmembers int;
    r account_ext_t;
    nrows int;
begin

    -- Ensure we got either a usable CID -OR- an E-MAIL
    if not (_cid > 0 or length(_email) > 3) then
        perform log_event( null, null, EVENT_DEVERR_GETTING_ACCOUNT,
            'no arguments supplied');
        return r;
    end if;

    -- If we didn't get a valid CID, get one via E-MAIL
    if not (_cid > 0) then
        _email := lower(_email);
        SELECT cid INTO _cid FROM members
        WHERE lower(fdecrypt(x_email)) = _email
            and userlevel = USERLEVEL_OWNER;
    end if;
    if not (coalesce(_cid, 0) > 0) then
        -- Search via E-MAIL returned no result either!
        return r;
    end if;


    -- Get Query Results

    SELECT count(*) INTO nmembers FROM Members WHERE cid = _cid;

    SELECT a.cid, a.status, a.quota, a.referrer, a.payment_type, 
            a.created, a.updated, a.expires, nmembers, m.mid,
            fdecrypt(x_userid), fdecrypt(x_email), fdecrypt(x_fname),
            fdecrypt(x_mi), fdecrypt(x_lname), fdecrypt(x_address1),
            fdecrypt(x_address2), fdecrypt(x_city), fdecrypt(x_state),
            fdecrypt(x_postalcode), fdecrypt(x_country), fdecrypt(x_phone),
            m.status, m.pwstatus, m.userlevel, m.tooltips, m.isadmin,
            m.logincount, m.created, m.updated
        INTO r FROM Accounts a JOIN Members m ON (a.owner_mid = m.mid)
        WHERE a.cid = _cid;


    -- Log if someone directly requested
    -- a non-existent account by CID
    get diagnostics nrows = ROW_COUNT;
    if (nrows = 0 and _cid > 0) then
        perform log_event( null, null, EVENT_DEVERR_GETTING_ACCOUNT,
            'Account ['||_cid||'] does not exist' );
        return r;
    end if;


    -- Success! Not notable enough to log
    return r;

end
$$ language plpgsql;

