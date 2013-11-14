
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
-- 2013-11-06 dbrown: added retrieval of column files.modified_by
-- 2013-11-11 dbrown: replaced eventcodes with constants; dev errors via RAISE
-- -----------------------------------------------------------------------------

create or replace function get_files(

    _fileuid    int    default null, --  \
    _folder_uid int    default null, --   > Search Criteria
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
    modified_by int,
    nrows       int,
    npages      int
    
) as $$
    
declare
    EC_DEVERR_GETTING_FILE constant char(4) := '9086';

    _nrows int;
    _npages int;

begin

    -- Argument processing: Make sure we have at least one
    if (_fileuid is null) and (_folder_uid is null) and (_mid is null) then
        raise warning 'get_files(): no search criteria supplied';
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
                fdecrypt(f.x_desc) as description ,
                f.modified_by
            from files f 
            where ( (_fileuid is not null)    and (f.uid = _fileuid) )
               or ( (_folder_uid is not null) and (f.folder_uid = _folder_uid) )
               or ( (_mid is not null)        and (f.mid = _mid) );

  
    -- Count results; if none, log exceptional reasons and exit 
    select count(*) into _nrows from files_out;
    if _nrows = 0 then
        if ( _fileuid is not null ) then
            if not exists ( select f.uid from files f where f.uid = _fileuid ) then
                raise warning 'get_files(): file [%] does not exist', _fileuid;
                perform log_event( null, null, EC_DEVERR_GETTING_FILE,
                            'file.uid '||_fileuid||' does not exist' );
            end if;
        elsif ( _folder_uid is not null) then
            if not exists (select f.uid from folders f where f.uid = _folder_uid) then
                raise warning 'get_files(): folder [%] does not exist', _folder_uid;
                perform log_event( null, null, EC_DEVERR_GETTING_FILE,
                            'folder.uid '||_folder_uid||' does not exist' );
            end if;
        elsif ( _mid is not null) then
            if not exists (select m.mid from members m where m.mid = _mid) then
                raise warning 'get_files(): mid [%] does not exist', _mid;
                perform log_event( null, null, EC_DEVERR_GETTING_FILE,
                            'mid'||_mid||' does not exist' );
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
            fo.filename, fo.description, fo.modified_by, _nrows, _npages
        from files_out fo
        order by created desc
        limit _pagesize offset (_page * _pagesize);
    
    return;
    
end
$$ language plpgsql;


