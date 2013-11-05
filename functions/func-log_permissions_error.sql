
-- ==============================================================================================
-- log_permissions_error()
-- ----------------------------------------------------------------------------------------------
-- Logs a permissions error using standardized messages
-- ----------------------------------------------------------------------------------------------
-- 2013-10-13 dbrown Created
-- 2013-10-16 dbrown returns void now
-- 2013-10-29 dbrown Revised -2 to be more precise
-- ----------------------------------------------------------------------------------------------

create or replace function log_permissions_error(

    code char(4),
    result int,
    scid int,
    smid int,
    tcid int,
    tmid int
    
) returns void as $$

declare
    message text;
    
begin

    case result    
        when  0 then message := 'A required argument was NULL';
        when -1 then message := 'source Member could not be found';
        when -2 then message := 'source Member userlevel > maxuserlevel';
        when -3 then message := 'target Member could not be found';
        when -4 then message := 'source and target Members in different Accounts';
        when -5 then message := 'target Member is an Account Owner (and not Self or Admin)';
        when -6 then message := 'target Member outranks source Member';
        else         message := 'Unknown permissions error value : ' || cast(result as text); 
    end case;

    perform log_event( scid, smid, code, message, tcid, tmid );
    return;
    
end;
$$ language plpgsql;

