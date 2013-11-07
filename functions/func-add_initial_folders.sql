
-- ======================================================================
-- function add_initial_folders--
--   adds starting folders to a member
--   by using default_folders as template
--   and filling in the rest with defaults
-- ----------------------------------------------------------------------
--     mid integer : member_mid that will own the created folders
-- ----------------------------------------------------------------------
-- 2013-10-09 dbrown : changed cid to mid (Members own us, not Accounts)
-- 2013-10-10 dbrown : moved meat into function add_folder()
-- 2013-10-13 dbrown : add_folder now needs source_mid, giving admin's
-- 2013-10-15 dbrown : folders.complete and folders.vieworder removed 
-------------------------------------------------------------------------

create or replace function add_initial_folders( _mid int ) 
    returns int as $$

declare
    admin_mid int;
    r record;
    c cursor for -- Get initial folders
        select fdecrypt(x_name) as fname, fdecrypt(x_desc) as fdesc
        from ref_defaultfolders;
        
begin

    for r in c loop -- Copy them with new owner    
        perform add_folder( 1, _mid, r.fname, r.fdesc, 0, 0 );
    end loop;
    
    return 1;
    
end;
$$ language plpgsql;

