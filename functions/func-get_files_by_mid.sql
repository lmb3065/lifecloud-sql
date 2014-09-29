
-----------------------------------------------------------------------------
-- get_files_by_mid
-----------------------------------------------------------------------------
-- _source_mid int : Member requesting the files.
-- _target_mid int : Member whose files are being requested.
--                 :   (0 returns entire CID if caller's userlevel <= 2)
-- _pagesize   int : Pagination size (default null = "all")
-- _page       int : Page of results to return (default 0)
-----------------------------------------------------------------------------
-- 2014-09-27 dbrown Created
-- 2014-09-28 dbrown TargetMID 0 returns caller's entire CID if authorized
-----------------------------------------------------------------------------

create or replace function get_files_by_mid
(
    _source_mid int,
    _target_mid int,
    _pagesize   int    default null,
    _page       int    default 0
)
returns table ( filerec file_t ) as $$
declare

    RETVAL_SUCCESS             constant int = 1;
    EVENT_AUTHERR_GETTING_FILE constant varchar = '6086';
    result  int;
    _target_cid int;
    _source_userlevel int;
    _nrows  int;
    _npages int;

begin

    if _target_mid = 0 then -- Return caller's entire MID

        select m.cid, m.userlevel into _target_cid, _source_userlevel
            from members m
            where m.mid = _source_mid;

        if _source_userlevel > 2 then return; end if; -- Not allowed

        create temporary table files_out on commit drop as
            select f.uid, f.folder_uid, f.mid, f.item_uid, f.created,
                    fdecrypt(f.x_name) as filename,
                    fdecrypt(f.x_desc) as description,
                    f.content_type, f.isprofile, f.category,
                    fdecrypt(f.x_form_data) as form_data,
                    f.modified_by, f.updated
                from files f
                where f.mid in (
                    select m.mid from members m where m.cid = _target_cid
                );

    else -- Normal query

        -- Check permissions

        select allowed into result
            from member_can_update_member(_source_mid, _target_mid);
        if (result < RETVAL_SUCCESS) then
            perform log_permissions_error( EVENT_AUTHERR_GETTING_FILE, result, 
                    null, _source_mid, null, _target_mid );
            return;
        end if;

        -- Get initial results

        create temporary table files_out on commit drop as
            select f.uid, f.folder_uid, f.mid, f.item_uid, f.created,
                    fdecrypt(f.x_name) as filename,
                    fdecrypt(f.x_desc) as description,
                    f.content_type, f.isprofile, f.category,
                    fdecrypt(f.x_form_data) as form_data,
                    f.modified_by, f.updated
                from files f
                where f.mid = _target_mid;

    end if;

    -- Calculate output paging

    select count(*) into _nrows from files_out;
    if (coalesce(_pagesize, 0) > 0) then
        _npages := _nrows / _pagesize;
        if (_nrows % _pagesize > 0) then _npages := _npages + 1; end if;
    else -- No paging, everything goes on 1 page
        _pagesize := null;
        _npages := 1;
    end if;

    -- Output final results

    return query
        select fo.uid, fo.folder_uid, fo.mid, fo.item_uid, fo.created,
            fo.filename, fo.description, fo.content_type, fo.isprofile,
            fo.category, fo.form_data, fo.modified_by, fo.updated,
            _nrows, _npages
        from files_out fo
        order by mid asc, updated desc, created desc
        offset (_page * _pagesize) limit _pagesize;

    return;

end
$$ language plpgsql;

