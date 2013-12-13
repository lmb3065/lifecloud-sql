-- ===========================================================================
--  function get_items
-- ---------------------------------------------------------------------------
--  Retrieves Items based on the FIRST criterion provided:
--    _item_uid     Simple index lookup for one item
--    _folder_uid   Retrieve all files in the specified folder.
--    _mid          Retrieve all files owner by the specified member.
--                    (If member is Owner, retrieve all files in account.)
-- ---------------------------------------------------------------------------
--  2013-12-12 dbrown: created
-- ---------------------------------------------------------------------------

create or replace function get_items(

    _item_uid       int default null,  -- \
    _folder_uid     int default null,  --  > Search criteria
    _mid            int default null,  -- /

    _pagesize       int     default null,  -- \  Output pagination
    _page           int     default 0      -- /     parameters

) returns table (

    uid         int,
    mid         int,
    cid         int,
    folder_uid  int,
    app_uid     int,
    item_name   text,
    item_desc   text,
    created     timestamp,
    updated     timestamp,
    nrows       int,
    npages      int

) as $$

declare
    EVENT_DEVERR_GETTING_ITEM   constant varchar := '9106';

    _nrows int;
    _npages int;

begin


    -- Ensure we have at least one argument
    if (coalesce( _item_uid, _folder_uid, _mid, 0 ) = 0) then
        perform log_event( null, null, EVENT_DEVERR_GETTING_ITEM, 'no criteria supplied' );
        return;
    end if;

    -- Enforce argument precedence ( ItemUID > FolderUID > MID )
    -- by NULLing out criteria we won't be using
    if (_item_uid   is not null) then _folder_uid := null; _mid := null; end if;
    if (_folder_uid is not null) then _mid := null; end if;


    -- Get initial results ---------------------------------------------------

    create temporary table items_out on commit drop as
        select i.uid, i.mid, i.cid, i.folder_uid, i.app_uid,
            fdecrypt(i.x_name) as item_name,
            fdecrypt(i.x_desc) as item_desc,
            i.created, i.updated
        from items i
        where (( _item_uid   is not null) and (i.uid = _item_uid ))
           or (( _folder_uid is not null) and (i.folder_uid = _folder_uid ))
           or (( _mid        is not null) and (i.mid = _mid ));


    -- Count results; if none, log exceptional reasons and exit

    select count(*) into _nrows from items_out;
    if _nrows = 0 then

        if ( _item_uid is not null ) then
            if not exists ( select i.uid from items i where i.uid = _item_uid ) then
                perform log_event( null, null, EVENT_DEVERR_GETTING_ITEM, 'item.uid '||_item_uid||' does not exist' );
            end if;
        elsif ( _folder_uid is not null ) then
            if not exists ( select f.uid from folders f where f.uid = _folder_uid ) then
                perform log_event( null, null, EVENT_DEVERR_GETTING_ITEM, 'folder.uid '||_folder_uid||' does not exist' );
            end if;
        elsif ( _mid is not null ) then
            if not exists ( select m.mid from members m where m.mid = _mid ) then
                perform log_event( null, null, EVENT_DEVERR_GETTING_ITEM, 'member.mid '||_mid||' does not exist' );
            end if;
        end if;

        return;
    end if;


    -- Calculate output paging ...
    if (coalesce(_pagesize, 0) > 0) then
        _npages := _nrows / _pagesize;
        if (_nrows % _pagesize > 0) then _npages := _npages + 1; end if;
    else -- No paging, everything goes on 1 page
        _pagesize := null;
        _npages := 1;
    end if;


    -- Output final results
    return query
        select io.uid, io.mid, io.cid, io.folder_uid, io.app_uid,
                io.item_name, io.item_desc, io.created, io.updated,
                _nrows, _npages
        from items_out io
        order by created desc
        limit _pagesize offset (_page * _pagesize);

    return;

end
$$ language plpgsql;
