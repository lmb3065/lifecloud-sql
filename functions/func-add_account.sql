-- ===========================================================================
-- function add_account
-- ---------------------------------------------------------------------------
-- Creates new Account record, AND Member record for the owner
-- ---------------------------------------------------------------------------
-- 2013-10-08 dbrown: Fixed outdated call to add_member; isAdmin defaults 0
-- 2013-10-09 dbrown: moved call to add_initial_folders into add_member
-- 2013-10-18 dbrown: Fixed outdated call to add_member (new 'profilepic')
-- 2013-10-24 dbrown: removed isAdmin argument
-- 2013-11-01 dbrown: Updated EventCodes
-- 2013-11-06 dbrown: Updated return values and lots of cleanup,
--       Replaced all magic codes and numbers with constants,
--       Null '_expires' arg now OK; default value is assigned by table,
--       E-mail is forced to lowercase before insert,
--       Removed unnecessary INSERT sanity check, add success logging
-- 2013-11-10 dbrown: includes owner e-mail in new success log
-- 2013-11-12 dbrown: Raises warning on error
-- 2013-11-13 dbrown: Deletes account entry if member-creation failed
--       Removed RAISE, added exception handling around SQL
--       Organized, more information in eventlog details
-- ---------------------------------------------------------------------------

create or replace function add_account(

    _email      varchar(64),
    _passwd     varchar(64),
    _lname      varchar(64),
    _fname      varchar(64),

    _mi         char(1)      default  '',
    _expires    timestamp    default  current_date + interval '1 year',
    _referrer   varchar(64)  default  '',
    _address1   varchar(64)  default  '',
    _address2   varchar(64)  default  '',
    _city       varchar(64)  default  '',
    _state      char(2)      default  '',
    _postalcode varchar(16)  default  '',
    _country    char(2)      default  '',
    _phone      varchar(20)  default  '',
    _status     int          default  0

) returns int as $$

declare
    EVENT_OK_ADDED_ACCOUNT       constant char(4) := '1020';
    EVENT_USERERR_ADDING_ACCOUNT constant char(4) := '4020';
    EVENT_DEVERR_ADDING_ACCOUNT  constant char(4) := '9020';
    RETVAL_OK                    constant int :=   1;
    RETVAL_ERR_ACCOUNT_EXISTS    constant int := -20;
--  RETVAL_ERR_MEMBER_EXISTS_EMAIL  from add_member = -21
--  RETVAL_ERR_MEMBER_EXISTS_USERID from add_member = -22
    RETVAL_ERR_EXCEPTION         constant int := -98;

    result int;
    fstatus int; fcid int; fmid int; -- "found" status, cid, mid
    newcid int; newmid int;
    C_QUOTA constant int := 100000000;

begin


    -- Check arguments --------------------------------------------------------

    _email := lower(_email); -- e-mail is case insensitive


    -- Check for existing account with this e-mail address
    SELECT a.status, a.cid, m.mid
        INTO fstatus, fcid, fmid
        FROM Accounts a JOIN Members m on (a.owner_mid = m.mid)
        WHERE _email = fdecrypt(m.x_email);

    if (fstatus = 9) then
        -- Found a temp signup account: Return that
        return fcid;

    elsif (fcid is not null) then
        -- Found an active account: Return error
        perform log_event( fcid, fmid, EVENT_USERERR_ADDING_ACCOUNT,
                    'Account <'||_email||'> already exists' );
        return RETVAL_ERR_ACCOUNT_EXISTS;

    end if;


    -- Add the Account -------------------------------------------------------

    declare
        errno  text;
        errmsg text;
        errdetail text;
    begin
        -- owner_mid = 0 until Owner is successfully created
        INSERT INTO Accounts ( owner_mid, status, quota, referrer, expires )
            VALUES ( 0, _status, C_QUOTA, _referrer, _expires );

    exception when others then
        -- Couldn't add account!
        get stacked diagnostics errno=RETURNED_SQLSTATE, errmsg=MESSAGE_TEXT, errdetail=PG_EXCEPTION_DETAIL;
        perform log_event(null, null, EVENT_DEVERR_ADDING_ACCOUNT, '['||errno||'] '||errmsg||' : '||errdetail);
        RETURN RETVAL_ERR_EXCEPTION;
    end;

    select last_value into newcid from accounts_cid_seq;
    perform log_event( newcid, null, EVENT_OK_ADDED_ACCOUNT, '['||newcid|| '] '||_email );


    -- Add the Member (Owner) -------------------------------------------------

    newmid := add_member( newcid, _fname, _lname, _mi, _passwd, _email, _email, null,
        _address1, _address2, _city, _state, _postalcode, _country, _phone,
        null, 0, 0, 0, 1 );

    if (newmid < RETVAL_OK) then
        -- Couldn't add member! Remove the Account we just created!
        -- (negative newmid contains error code)
        DELETE FROM Accounts WHERE owner_mid = 0;
        return newmid;
    end if;

    -- Link Member to Account as Owner
    update Accounts set owner_mid = newmid where cid = newcid;

    -- Done
    return newcid;

end;
$$ language plpgsql;

