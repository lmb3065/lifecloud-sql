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
-- 2013-11-14 dbrown: Organization, no more RAISE
-- 2013-11-16 dbrown: New (output) columm content_type
-- 2013-11-23 dbrown: Fixed outdated eventcodes
-- 2013-11-23 dbrown: Changes for Forms: added columns isForm and category;
--              extracted output def'n into a type so get_forms can use it too
-- 2013-12-12 dbrown: added item_uid
-- -----------------------------------------------------------------------------

create or replace function get_files(

    _fileuid    int    default null, --  \
    _folder_uid int    default null, --   > Search Criteria
    _mid        int    default null, --  /
    _pagesize   int    default null, --  \  Pagination
    _page       int    default 0     --  /    Options

) returns table ( filerec file_t ) as $$

declare
    EVENT_DEVERR_GETTING_FILE constant char(4) := '9086';

    _nrows int;
    _npages int;

begin

    -- Check arguments -------------------------------------------------------------

    -- Ensure we have at least one argument
    if (coalesce(_fileuid, _folder_uid, _mid, 0) = 0) then
        perform log_event( null, null, EVENT_DEVERR_GETTING_FILE,
                    'no arguments supplied');
        return;
    end if;

    -- Enforce argument precedence: fileuid > folderuid > mid
    -- NULL out criteria we won't be using
    if (_fileuid is not null) then
        _folder_uid := null;
        _mid := null;
    end if;
    if (_folder_uid is not null) then
        _mid := null;
    end if;



    -- Get initial results ---------------------------------------------------------

    create temporary table files_out on commit drop as
        select f.uid, f.folder_uid, f.mid, f.item_uid, f.created,
                fdecrypt(f.x_name) as filename,
                fdecrypt(f.x_desc) as description,
                f.content_type,
                f.isform, f.category,
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
                perform log_event( null, null, EVENT_DEVERR_GETTING_FILE,
                            'file.uid '||_fileuid||' does not exist' );
            end if;
        elsif ( _folder_uid is not null) then
            if not exists (select f.uid from folders f where f.uid = _folder_uid) then
                perform log_event( null, null, EVENT_DEVERR_GETTING_FILE,
                            'folder.uid '||_folder_uid||' does not exist' );
            end if;
        elsif ( _mid is not null) then
            if not exists (select m.mid from members m where m.mid = _mid) then
                perform log_event( null, null, EVENT_DEVERR_GETTING_FILE,
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



    -- Output final results --------------------------------------------------------

    return query
        select fo.uid, fo.folder_uid, fo.mid, fo.item_uid, fo.created,
            fo.filename, fo.description, fo.content_type, fo.isform,
            fo.category, fo.modified_by,
            _nrows, _npages
        from files_out fo
        order by created desc
        limit _pagesize offset (_page * _pagesize);

    return;

end
$$ language plpgsql;
