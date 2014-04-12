-----------------------------------------------------------------------------
-- table REMINDERS
-----------------------------------------------------------------------------
--   A REMINDER, or an "alert", is an email or text message (or a LifeCloud
-- website popup) that gets sent on a particular date, reminding the user of
-- an upcoming event. The email/text contains the name and date of the event.
--   Reminders are not the same as calendar events: a reminder is a
-- notification that an event is about to occur.
-----------------------------------------------------------------------------
-- advance_days: number of days in advance of event_date to send reminder
-- recurrence: 0=not recurring
--             1=send reminder daily, 2=weekly, 3=monthly, 4=anually
-----------------------------------------------------------------------------
-- 2014-04-12 dbrown : Created
-----------------------------------------------------------------------------

create table Reminders
(
    uid             serial      not null    primary key,
    mid             int         not null    references Members,
    event_name      text        not null,
    event_date      timestamp   not null,
    advance_days    int         not null,
    item_uid        int                     references Items(uid),
    recurrence      int,
    sent            int
);
alter table Reminders owner to pgsql;

