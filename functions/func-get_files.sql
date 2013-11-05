
-- -----------------------------------------------------------------------------
--  get_files()
-- -----------------------------------------------------------------------------
--  Retrieves row(s) from Files based on the FIRST criterion provided.
--   _fileuid        : Simple index lookup for one file. 
--   _folder_uid      : Retrieves all files in the specified folder.
--   _mid            : Retrieves all files owned by the specified member.
--   _pagesize _page : Standard pagination arguments
-- -----------------------------------------------------------------------------
--  If you receive no rows, your search was invalid (see the event log)
--  or the folder/MID you selected owned no files.
-- -----------------------------------------------------------------------------
-- 2013-10-29 dbrown: Created
-- 2013-10-30 dbrown: Added filename/description, simplified structure
-- 2013-11-01 dbrown: Further simplified structure, standardized failure output
-- 2013-11-01 dbrown: Now logs events on calling errors
-- 2013-11-01 dbrown: Revised event codes
-- -----------------------------------------------------------------------------

create or replace function get_files(

    _fileuid    int    default null, --  \
    _folder_uid  int    default null, --   > Search Criteria
    _mid        int    default null, --  /
    _pagesize   int    default null, --  \  Pagination
    _page       int    default 0     --  /    Options
    
) returns table (

    uid         int, 
    fid         int, 
    mid         int, 
    created     timestamp, 
    filename    text,
    description text,
    nrows       int,
    npages      int
    
) as $$
    
declare
    _nrows int;
    _npages int;
    tmp int;

begin

    -- Argument processing: Make sure we have at least one
    if (_fileuid is null) and (_folder_uid is null) and (_mid is null) then
        perform log_event( null, null, '9500', 'get_files(): no search criteria' );
        return;
    end if;
    
    -- Argument precedence: fileuid > folderuid > mid
    if (_fileuid is not null) then
        _folder_uid := null; _mid := null; end if;
    if (_folder_uid is not null) then 
        _mid = null; end if;

    -- Get initial results
    create temporary table files_out on commit drop as
        select f.uid, f.folder_uid, f.mid, f.created,
                fdecrypt(f.x_name) as filename,
                fdecrypt(f.x_desc) as description 
            from files f 
            where ( (_fileuid is not null)   and (f.uid = _fileuid) )
               or ( (_folder_uid is not null) and (f.folder_uid = _folder_uid) )
               or ( (_mid is not null)       and (f.mid = _mid) );

  
    -- Count results; if none, log exceptional reasons and exit 
    select count(*) into _nrows from files_out;
    if _nrows = 0 then
        if ( _fileuid is not null) then
            select fi.uid into tmp from files fi where fi.uid = _fileuid;
            if ( tmp is null ) then
                perform log_event( null,null, '9085',
                            'get_files(): nonexistent file.uid requested' );
            end if;
        elsif ( _folder_uid is not null) then
            select fo.uid into tmp from folders fo where fo.uid = _folder_uid;
            if ( tmp is null ) then
                perform log_event( null,null, '9085',
                            'get_files(): nonexistent folder.uid requested' );
            end if;
        elsif ( _mid is not null) then
            select m.mid into tmp from members m where m.mid = _mid;
            if ( tmp is null ) then
                perform log_event( null,null, '9085',
                            'get_files(): nonexistent member.mid requested');
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
        select fo.uid, fo.folder_uid, fo.mid, fo.created, 
            fo.filename, fo.description, _nrows, _npages
        from files_out fo
        order by created desc
        limit _pagesize offset (_page * _pagesize);
    
    return;
    
end
$$ language plpgsql;


