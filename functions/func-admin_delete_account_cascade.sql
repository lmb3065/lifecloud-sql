
-----------------------------------------------------------------------------
-- function admin_delete_account_cascade
-----------------------------------------------------------------------------
-- DELETES ALL TRACE OF AN ACCOUNT.  Use with caution
-----------------------------------------------------------------------------

create or replace function admin_delete_account_cascade(

    arg_cid int
    
) returns void as $$

declare
    EC_OK_ADMIN_DELETED_ACCOUNT constant varchar := '1029';

begin

    create temporary table account_members on commit drop as
        select mid from members where cid = arg_cid;
        
    delete from files   where       mid in (select mid from account_members);
    delete from folders where       mid in (select mid from account_members);
    delete from member_apps where   mid in (select mid from account_members);
    delete from profilepics where   mid in (select mid from account_members);
    delete from sessions where      mid in (select mid from account_members);    
    delete from members where       mid in (select mid from account_members);
    drop table account_members;
        
    delete from events  where (cid = arg_cid) or (target_cid = arg_cid);

    perform log_event( arg_cid, null, EC_OK_ADMIN_DELETED_ACCOUNT,
                'Nuked via admin_delete_account_cascade()' );
    
    raise notice 'All trace of CID % has been permanently destroyed!', arg_cid;
    
end
$$ language plpgsql;


