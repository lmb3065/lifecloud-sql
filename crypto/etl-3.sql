
 -- ETL PART 3 : RE-ENCRYPTION


create or replace function etl3() returns int as $$
declare

    folders_c cursor for select * from _ct_Folders;
    items_c   cursor for select * from _ct_Items;
    files_c   cursor for select * from _ct_Files;
    members_c cursor for select * from _ct_Members;
    ipn_c     cursor for select * from _ct_IPN;
    events_c  cursor for select * from _ct_Events;
    defaultfolders_c cursor for select * from _ct_DefaultFolders;
    sessions_c cursor for select * from _ct_Sessions;

begin

    -----------------------------------------------------------------------------
    raise notice 'Re-Encrypting Folders';

    for r in folders_c loop
        update Folders set
            x_name = fencrypt(r.name),
            x_desc = fencrypt(r.desc)
        where Folders.uid = r.uid;
    end loop;

    -----------------------------------------------------------------------------
    raise notice 'Re-Encrypting Items';

    for r in items_c loop
        update Items set
            x_name = fencrypt(r.name),
            x_desc = fencrypt(r.desc)
        where Items.uid = r.uid;
    end loop;

    -----------------------------------------------------------------------------
    raise notice 'Re-Encrypting Files';

    for r in files_c loop
        update Files set
            x_name      = fencrypt(r.name),
            x_desc      = fencrypt(r.desc),
            x_form_data = fencrypt(r.form_data)
        where Files.uid = r.uid;
    end loop;

    -----------------------------------------------------------------------------
    raise notice 'Re-Encrypting Members';

    for r in members_c loop
        update Members set
            x_userid   = fencrypt(r.userid),
            x_email    = fencrypt(r.email),
            x_fname    = fencrypt(r.fname),
            x_mi       = fencrypt(r.mi),
            x_lname    = fencrypt(r.lname),
            x_address1 = fencrypt(r.address1),
            x_address2 = fencrypt(r.address2),
            x_city     = fencrypt(r.city),
            x_state    = fencrypt(r.state),
            x_postalcode = fencrypt(r.postalcode),
            x_country    = fencrypt(r.country),
            x_phone      = fencrypt(r.phone),
            x_alertphone = fencrypt(r.alertphone),
            x_alertemail = fencrypt(r.alertemail)
        where Members.mid = r.mid;
    end loop;

    -----------------------------------------------------------------------------
    raise notice 'Re-Encrypting IPNs';

    for r in ipn_c loop
        update IPN set
            x_business        = fencrypt(r.business),
            x_receiver_email  = fencrypt(r.receiver_email),
            x_item_name       = fencrypt(r.item_name),
            x_item_number     = fencrypt(r.item_number),
            x_invoice         = fencrypt(r.invoice),
            x_custom          = fencrypt(r.custom),
            x_memo            = fencrypt(r.memo),
            x_payment_status  = fencrypt(r.payment_status),
            x_pending_reason  = fencrypt(r.pending_reason),
            x_reason_code     = fencrypt(r.reason_code),
            x_payment_date    = fencrypt(r.payment_date),
            x_txn_id          = fencrypt(r.txn_id),
            x_txn_type        = fencrypt(r.txn_type),
            x_payment_type    = fencrypt(r.payment_type),
            x_username        = fencrypt(r.username),
            x_password        = fencrypt(r.password), 
            x_subscr_id       = fencrypt(r.subscr_id),
            x_first_name      = fencrypt(r.first_name),
            x_last_name       = fencrypt(r.last_name),
            x_address_name    = fencrypt(r.address_name),
            x_address_street  = fencrypt(r.address_street),
            x_address_city    = fencrypt(r.address_city),
            x_address_state   = fencrypt(r.address_state),
            x_address_zip     = fencrypt(r.address_zip),
            x_address_country = fencrypt(r.address_country),
            x_address_status  = fencrypt(r.address_status),
            x_payer_email     = fencrypt(r.payer_email),
            x_payer_id        = fencrypt(r.payer_id),
            x_payer_status    = fencrypt(r.payer_status)
        where IPN.uid = r.uid;
    end loop;

    -----------------------------------------------------------------------------
    raise notice 'Re-Encrypting Events';

    for r in events_c loop
        update events set x_data = fencrypt(r.data)
        where events.eid = r.eid;
    end loop;

    -----------------------------------------------------------------------------
    raise notice 'Re-Encrypting DefaultFolders';

    truncate table ref_defaultfolders;
    for r in defaultfolders_c loop
        insert into ref_defaultfolders
        values ( 
            fencrypt(r.name),
            fencrypt(r.desc)
        );
    end loop;

    -----------------------------------------------------------------------------
    raise notice 'Re-Encrypting Session IPs';

    for r in sessions_c loop
        update Sessions set x_ipaddr = fencrypt(r.ipaddr)
        where Sessions.sid = r.sid;
    end loop;

    return 0;
end;
$$ language plpgsql;

