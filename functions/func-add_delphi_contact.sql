-----------------------------------------------------------------------------
-- function add_delphi_contact
-----------------------------------------------------------------------------
-- Inserts a new email address for user requesting free PDFs from Delphi
--
-- 2016-04-21 dbrown: created.  No Logging and almost no input checking.
-----------------------------------------------------------------------------

create or replace function add_delphi_contact(

    _email text,
    _fname text,
    _lname text

) returns int as $$

declare

    RETVAL_SUCCESS              constant int :=  1;
    RETVAL_ERR_ARG_INVALID      constant int :=  0;

begin

    if 0 = length(_email) then 
        return RETVAL_ERR_ARG_INVALID;
    end if;

    INSERT INTO delphi_contacts (x_email, x_fname, x_lname)
    VALUES ( fencrypt(_email), fencrypt(_fname), fencrypt(_lname) );

    return RETVAL_SUCCESS;

end;

$$ language plpgsql;
