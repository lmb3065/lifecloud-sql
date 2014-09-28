
create or replace function get_files_by_cid
(
    _source_mid int,
    _target_cid int,
    _pagesize   int    default null,
    _page       int    default 0
)
returns table ( filerec file_t ) as $$

-----------------------------------------------------------------------------
-- get_files_by_cid
-----------------------------------------------------------------------------
-- _source_mid int : Member requesting the files.
-- _target_cid int : Account (CID) to list files from.
-- _pagesize   int : Pagination size (default null = "all")
-- _page       int : Page of results to return (default 0)
-----------------------------------------------------------------------------
-- Members with isAdmin = 1 may look at any CID
-- Members with userLevel <= 2 may look at their own CID
-- Others may not look at any CID
-----------------------------------------------------------------------------
-- 2014-09-27 dbrown Created
-----------------------------------------------------------------------------

declare

    RETVAL_SUCCESS             constant int = 1;
    RETVAL_ERR_NOT_ALLOWED      constant int := -80;
    EVENT_AUTHERR_GETTING_FILE constant varchar = '6086';
    EVENT_DEVERR_GETTING_FILE  constant varchar  = '9086';
    _source_cid int = null;
    _source_isadmin int = null;
    _source_userlevel int = null;
    _nrows int;
    _npages int;

begin

    -- Determine caller's security clearance
    select m.cid, m.isadmin, m.userlevel 
        into _source_cid, _source_isadmin, _source_userlevel
        from members m where m.mid = _source_mid;

    if _source_cid is null then return; end if;
    if _source_userlevel > 2 then return; end if;
    if (_source_cid <> _target_cid) and (_source_isadmin <> 1) then return; end if;

    -- Get initial results

    create temporary table files_out on commit drop as
        select f.uid, f.folder_uid, f.mid, f.item_uid, f.created,
                fdecrypt(f.x_name) as filename,
                fdecrypt(f.x_desc) as description,
                f.content_type, f.isprofile, f.category,
                fdecrypt(f.x_form_data) as form_data,
                f.modified_by, f.updated
            from files f
            where f.mid in (select m.mid from members m where m.cid = _target_cid);

    -- Calculate output paging

    select count(*) into _nrows from files_out;
    if (coalesce(_pagesize, 0) > 0) then
        _npages := _nrows / _pagesize;
        if (_nrows % _pagesize > 0) then _npages := _npages + 1; end if;
    else -- No paging, everything goes on 1 page
        _pagesize := null;
        _npages := 1;
    end if;

    return query
        select fo.uid, fo.folder_uid, fo.mid, fo.item_uid, fo.created,
            fo.filename, fo.description, fo.content_type, fo.isprofile,
            fo.category, fo.form_data, fo.modified_by, fo.updated,
            _nrows, _npages
        from files_out fo
        order by updated desc, created desc
        offset (_page * _pagesize) limit _pagesize;

    return;
end
$$ language plpgsql;
