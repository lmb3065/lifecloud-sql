
 -- ETL PART 3 : INSERTION


    alter table files       drop constraint files_mid_fkey;
    alter table folders     drop constraint folders_mid_fkey;
    alter table items       drop constraint items_mid_fkey;
    alter table member_apps drop constraint member_apps_mid_fkey;
    alter table profilepics drop constraint profilepics_mid_fkey;
    alter table reminders   drop constraint reminders_mid_fkey;
    alter table sessions    drop constraint sessions_mid_fkey;    
    alter table files       drop constraint files_folder_uid_fkey;
    alter table items       drop constraint items_folder_uid_fkey;

    truncate table members;
    truncate table folders;
    truncate table files;
    truncate table items;
    truncate table ipn;

create or replace function etl3() returns int as $$
declare

    folders_c cursor for select * from _ct_Folders;
    items_c   cursor for select * from _ct_Items;
    files_c   cursor for select * from _ct_Files;
    members_c cursor for select * from _ct_Members;
    ipn_c     cursor for select * from _ct_IPN;

begin

    -----------------------------------------------------------------------------
    raise notice 'Adding Folders';

    truncate table Folders;
    for r in folders_c loop
        insert into Folders (
            uid, mid, cid, x_name, x_desc,
            app_uid, created, updated )
        values (
            r.uid, r.mid, r.cid, fencrypt(r.name), fencrypt(r.desc),
            r.app_uid, r.created, r.updated );
    end loop;

    -----------------------------------------------------------------------------
    raise notice 'Adding Items';

    truncate table Items;
    for r in items_c loop
        insert into Items (
            uid, mid, cid, 
            folder_uid, app_uid, itemtype,
            x_name, x_desc, 
            created, updated, modified_by )
        values (
            r.uid, r.mid, r.cid, 
            r.folder_uid, r.app_uid, r.itemtype,
            fencrypt(r.name), fencrypt(r.desc), 
            r.created, r.updated, r.modified_by );
    end loop;

    -----------------------------------------------------------------------------
    raise notice 'Adding Files';

    truncate table Files;
    for r in files_c loop
        insert into Files (
            uid, folder_uid, mid, item_uid,
            x_name, x_desc,
            content_type, isprofile, category,
            x_form_data, modified_by, created, updated )
        values (
            r.uid, r.folder_uid, r.mid, r.item_uid,
            fencrypt(r.name), fencrypt(r.desc),
            r.content_type, r.isprofile, r.category,
            fencrypt(r.form_data), r.modified_by, r.created, r.updated );
    end loop;

    -----------------------------------------------------------------------------
    raise notice 'Adding Members';

    truncate table Members;
    for r in members_c loop
        insert into Members (
            mid, cid, h_passwd, x_userid, x_email,
            h_profilepic,
            x_fname, x_mi, x_lname,
            x_address1, x_address2, x_city,
            x_state, x_postalcode, x_country,
            x_phone,
            alerttype, x_alertphone, x_alertemail,
            status, pwstatus, userlevel, tooltips, 
            isadmin, logincount, created, updated )
        values (
            r.mid, r.cid, r.h_passwd, fencrypt(r.userid), fencrypt(r.email),
            r.h_profilepic,
            fencrypt(r.fname), fencrypt(r.mi), fencrypt(r.lname),
            fencrypt(r.address1), fencrypt(r.address2), fencrypt(r.city),
            fencrypt(r.state), fencrypt(r.postalcode), fencrypt(r.country),
            fencrypt(r.phone),
            r.alerttype, fencrypt(r.alertphone), fencrypt(r.alertemail),
            r.status, r.pwstatus, r.userlevel, r.tooltips,
            r.isadmin, r.logincount, r.created, r.updated );
    end loop;

    -----------------------------------------------------------------------------
    raise notice 'Adding IPNs';

    truncate table IPN;
    for r in ipn_c loop
        insert into IPN (
            UID,
            IPNReceived,
            x_business,
            x_receiver_email,
            x_item_name,
            x_item_number,
            quantity,
            x_invoice,
            x_custom,
            x_memo,
            tax,
            x_payment_status,
            x_pending_reason,
            x_reason_code,
            x_payment_date,
            x_txn_id,
            x_txn_type,
            x_payment_type,
            mc_gross,
            mc_fee,
            mc_currency,
            settle_amount,
            settle_currency,
            exchange_rate,
            payment_gross,
            payment_fee,
            subscr_date,
            subscr_effective,
            period1,
            period2,
            period3,
            amount1,
            amount2,
            amount3,
            mc_amount1,
            mc_amount2,
            mc_amount3,
            recurring,
            reattempt,
            retry_at,
            recur_times,
            x_username,
            x_password,
            x_subscr_id,
            x_first_name,
            x_last_name,
            x_address_name,
            x_address_street,
            x_address_city,
            x_address_state,
            x_address_zip,
            x_address_country,
            x_address_status,
            x_payer_email,
            x_payer_id,
            x_payer_status,
            notify_version,
            verify_sign,
            post_status,
            post_response,
            HAStatus )
        values (
            r.UID,
            r.IPNReceived,
            fencrypt(r.business),
            fencrypt(r.receiver_email),
            fencrypt(r.item_name),
            fencrypt(r.item_number),
            r.quantity,
            fencrypt(r.invoice),
            fencrypt(r.custom),
            fencrypt(r.memo),
            r.tax,
            fencrypt(r.payment_status),
            fencrypt(r.pending_reason),
            fencrypt(r.reason_code),
            fencrypt(r.payment_date),
            fencrypt(r.txn_id),
            fencrypt(r.txn_type),
            fencrypt(r.payment_type),
            r.mc_gross,
            r.mc_fee,
            r.mc_currency,
            r.settle_amount,
            r.settle_currency,
            r.exchange_rate,
            r.payment_gross,
            r.payment_fee,
            r.subscr_date,
            r.subscr_effective,
            r.period1,
            r.period2,
            r.period3,
            r.amount1,
            r.amount2,
            r.amount3,
            r.mc_amount1,
            r.mc_amount2,
            r.mc_amount3,
            r.recurring,
            r.reattempt,
            r.retry_at,
            r.recur_times,
            fencrypt(r.username),
            fencrypt(r.password),
            fencrypt(r.subscr_id),
            fencrypt(r.first_name),
            fencrypt(r.last_name),
            fencrypt(r.address_name),
            fencrypt(r.address_street),
            fencrypt(r.address_city),
            fencrypt(r.address_state),
            fencrypt(r.address_zip),
            fencrypt(r.address_country),
            fencrypt(r.address_status),
            fencrypt(r.payer_email),
            fencrypt(r.payer_id),
            fencrypt(r.payer_status),
            r.notify_version,
            r.verify_sign,
            r.post_status,
            r.post_response,
            r.HAStatus );
    end loop;

    -----------------------------------------------------------------------------

    return 0;
end;
$$ language plpgsql;


/* 
    ETL_21 Encrypt/Insert Members
    ETL_22 Encrypt/Insert Folders
    ETL_23 Encrypt/Insert Files
    ETL_24 Encrypt/Insert Items
    ETL_25 Encrypt/Insert IPN
*/
