-- =============================================================================
-- function find_files()
-- -----------------------------------------------------------------------------
-- 2015-09-03 Created
-- 2015-09-03 Added functionality: Permissions checked, 0 returns entire CID
-----------------------------------------------------------------------------

create or replace function find_files(

   _source_mid int,
   _target_mid int,
   _searchstr text default null,
   _pagesize int default null,
   _page int default 0

) returns table ( filerec file_t ) as $$
declare

    RETVAL_SUCCESS             constant int := 1;
    RETVAL_ERR_NOT_ALLOWED     constant int := -80;
    EVENT_AUTHERR_GETTING_FILE constant varchar := '6086';
    result int;
    _source_cid int;
    _source_userlevel int;
    _nrows int;
    _npages int;

begin

    if (_searchstr is null) then
        return;
    end if;

    if _target_mid = 0 then -- Search caller's CID only

        select m.cid, m.userlevel into _source_cid, _source_userlevel
            from members m where m.mid = _source_mid;
        if _source_userlevel > 2 then
            perform log_permissions_error( EVENT_AUTHERR_GETTING_FILE,
                RETVAL_ERR_NOT_ALLOWED, _source_cid, _source_mid, _source_cid, _target_mid); 
            return;
        end if;

        create temporary table files_out on commit drop as
            select f.uid, f.folder_uid, f.mid, f.item_uid, f.created,
            fdecrypt(f.x_name) as filename,
            fdecrypt(f.x_desc) as description,
            f.content_type, f.isprofile, f.category,
            fdecrypt(f.x_form_data) as form_data,
            f.modified_by, f.updated, 
            fdecrypt(m.x_fname) as ownerfname, 
            fdecrypt(m.x_lname) as ownerlname
        from files f join members m on (f.mid = m.mid)
            where ( _source_cid = m.cid )
            and ((_searchstr is null or (fdecrypt(f.x_name) ilike '%' || _searchstr || '%'))
            or   (_searchstr is null or (fdecrypt(f.x_desc)  ilike '%' || _searchstr || '%')));

    else -- Regular query

        select allowed into result
            from member_can_view_member( _source_mid, _target_mid);
        if (result < RETVAL_SUCCESS) then
            perform log_permissions_error( EVENT_AUTHERR_GETTING_FILE, result,
                null, _source_mid, null, _target_mid );
            return;
        end if;

        create temporary table files_out on commit drop as
            select f.uid, f.folder_uid, f.mid, f.item_uid, f.created,
            fdecrypt(f.x_name) as filename,
            fdecrypt(f.x_desc) as description,
            f.content_type, f.isprofile, f.category,
            fdecrypt(f.x_form_data) as form_data,
            f.modified_by, f.updated, 
            fdecrypt(m.x_fname) as ownerfname, 
            fdecrypt(m.x_lname) as ownerlname
        from files f join members m on (f.mid = m.mid)
        where ( _target_mid = m.mid)
          and ((_searchstr is null or (fdecrypt(f.x_name) ilike '%' || _searchstr || '%'))
          or (_searchstr is null or (fdecrypt(f.x_desc)  ilike '%' || _searchstr || '%')));

    end if;

    -----

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
            fo.ownerfname, fo.ownerlname,
            _nrows, _npages
        from files_out fo
        order by isprofile desc, ownerfname asc, updated desc, created desc
        offset (_page * _pagesize) limit _pagesize;


end
$$ language plpgsql;
