
-----------------------------------------------------------------------------
-- get_files_by_uid
-----------------------------------------------------------------------------
-- _source_mid int : Member requesting the file.
-- _file_uid   int : File to retrieve
-----------------------------------------------------------------------------
-- 2014-09-27 dbrown Created
-- 2014-09-28 dbrown Add ownerfname, ownerlname
-----------------------------------------------------------------------------

create or replace function get_file_by_uid
(
    _source_mid int,
    _file_uid int
)
returns table ( filerec file_t) as $$
declare

    RETVAL_SUCCESS      constant int = 1;
    EVENT_AUTHERR_GETTING_FILE constant varchar = '6086';
    EVENT_DEVERR_GETTING_FILE constant varchar = '9086';
    _result int;
    _owner_mid int;

begin

    -- Determine who owns the file
    select f.mid into _owner_mid
        from files f where f.uid = _file_uid;
    if _owner_mid is null then
        perform log_event( null, null, EVENT_DEVERR_GETTING_FILE,
                        'FileUID ' || _file_uid || ' not found');
        return;
    end if;

    -- Check permissions

    select allowed into _result
        from member_can_update_member( _source_mid, _owner_mid);
    if (_result < RETVAL_SUCCESS) then
        perform log_permissions_error( EVENT_AUTHERR_GETTING_FILE, _result,
                                      null, _source_mid, null, _owner_mid );
        return;
    end if;

    -- Get result (one item)

    return query
        select f.uid, f.folder_uid, f.mid, f.item_uid, f.created,
                fdecrypt(f.x_name) as filename,
                fdecrypt(f.x_desc) as description,
                f.content_type, f.isprofile, f.category,
                fdecrypt(f.x_form_data) as form_data,
                f.modified_by, f.updated, 
                fdecrypt(m.x_fname) as ownerfname,
                fdecrypt(m.x_lname) as ownerlname,
                1, 1
            from files f join members m on (f.mid = m.mid)
            where f.uid = _file_uid;

    return;

end
$$ language plpgsql;
