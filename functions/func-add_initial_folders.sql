
-- =============================================================================
-- function add_initial_folders--
--   adds starting folders to a member using default_folders as template
-- -----------------------------------------------------------------------------
-- ARGUMENT _mid integer : member_mid that will own the created folders
-- -----------------------------------------------------------------------------
-- RETURNS 1 : RETVAL_SUCCESS
--       -25 : RETVAL_ERR_FOLDER_EXISTS : This member already has folders.
-- -----------------------------------------------------------------------------
-- 2013-10-09 dbrown : changed cid to mid (Members own us, not Accounts)
-- 2013-10-10 dbrown : moved meat into function add_folder()
-- 2013-10-13 dbrown : add_folder now needs source_mid, giving admin's
-- 2013-10-15 dbrown : folders.complete and folders.vieworder removed
-- 2013-11-07 dbrown : updated return values and event codes
--                     Replaced magic retvals and eventcodes with constants
--                     quits if member already has folders
--------------------------------------------------------------------------------

create or replace function add_initial_folders( _mid int ) 
    returns int as $$

declare
    RETVAL_SUCCESS           constant int :=   1;
    RETVAL_ERR_FOLDER_EXISTS constant int := -25;
    EC_DEVERR_ADDING_FOLDER  constant varchar := '9070';

    nfolders int;
    admin_mid int;
    r record;
    c cursor for -- Get initial folders
        SELECT fdecrypt(x_name) AS fname,
               fdecrypt(x_desc) AS fdesc
            FROM ref_defaultfolders;
        
begin

    -- Bail out if user already has folders;
    -- we don't want to duplicate them.
    
    SELECT count(*) INTO nfolders 
        FROM Folders 
        WHERE mid = _mid;
        
    if (nfolders > 0) then
        perform log_event( null, _mid, EC_DEVERR_ADDING_FOLDER, 'User already has folders' );
        return RETVAL_ERR_FOLDER_EXISTS;
    end if;

    
    -- Copy the folders to their new owner
    for r in c loop    
        perform add_folder( 1, _mid, r.fname, r.fdesc, 0, 0 );
    end loop;
    
    return RETVAL_SUCCESS;
    
end;
$$ language plpgsql;

