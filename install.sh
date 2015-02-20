#!/bin/sh

## -----------------------------------------------------------------------------
##  install.sh
## -----------------------------------------------------------------------------
##     Drops any existing LifeCloud (lc) database, recreates its structure from
##  the SQL source files, then runs some initializing functions to populate it
##  with essential data
## -----------------------------------------------------------------------------
##    This file is part of the LifeCloud Database installation package.  You
##  should have already run "transfer.sh" to copy this package to the
##  destination.  Run this script, "install.sh", in the root directory of the
##  installation package.  Afterward, the "lc" database should be completely
##  installed and ready to use.
##     You may need to say : pg_ctl restart -D /opt/pgsql/data/ -m fast
## -----------------------------------------------------------------------------
## 2013-10-11 dbrown : Unrolled table loading loop -- the tables were being
##                     created in a sequence that caused dependency errors
## 2013-11-05 dbrown : removed pg_ctl, added ref_apps and admin_create_applist
## 2013-11-24 dbrown : adds tables ref_categories, ref_forms
##                     runs new admin_create_categories(), admin_create_forms()
## 2014-01-10 dbrown:  Added TEST SUITE to installation
## 2014-05-02 dbrown:  Should now bail out if createdb fails
## 2014-05-02 dbrown:  Fixed step numbering
## -----------------------------------------------------------------------------

lcdir=.
pgdatadir=/opt/pgsql/data/

echo
echo LifeCloud Database Installer

echo 1/9 Dropping old LifeCloud database
dropdb lc

echo 2/9 Creating new LifeCloud database
createdb lc || exit

echo 3/9 Installing Crypto Functions
psql --dbname=lc --username=pgsql --quiet --file=$lcdir/crypto/pgcrypto.sql
for i in $lcdir/crypto/func-*.sql; do
    psql --dbname=lc --username=pgsql --quiet --file=$i
done

echo 4/9 installing Data Types
for i in $lcdir/types/type-*.sql; do
    psql --dbname=lc --username=pgsql --quiet --file=$i
done

echo 5/9 Installing Tables
psql --dbname=lc --username=pgsql --quiet --file=$lcdir/tables/table-pgpkeys.sql
psql --dbname=lc --username=pgsql --quiet --file=$lcdir/tables/table-ref_itemtypes.sql
psql --dbname=lc --username=pgsql --quiet --file=$lcdir/tables/table-ref_categories.sql
psql --dbname=lc --username=pgsql --quiet --file=$lcdir/tables/table-ref_eventcodes.sql
psql --dbname=lc --username=pgsql --quiet --file=$lcdir/tables/table-ref_retvals.sql
psql --dbname=lc --username=pgsql --quiet --file=$lcdir/tables/table-ref_defaultfolders.sql
psql --dbname=lc --username=pgsql --quiet --file=$lcdir/tables/table-ref_forms.sql
psql --dbname=lc --username=pgsql --quiet --file=$lcdir/tables/table-ref_apps.sql
psql --dbname=lc --username=pgsql --quiet --file=$lcdir/tables/table-accounts.sql
psql --dbname=lc --username=pgsql --quiet --file=$lcdir/tables/table-members.sql
psql --dbname=lc --username=pgsql --quiet --file=$lcdir/tables/table-events.sql
psql --dbname=lc --username=pgsql --quiet --file=$lcdir/tables/table-folders.sql
psql --dbname=lc --username=pgsql --quiet --file=$lcdir/tables/table-files.sql
psql --dbname=lc --username=pgsql --quiet --file=$lcdir/tables/table-items.sql
psql --dbname=lc --username=pgsql --quiet --file=$lcdir/tables/table-profilepics.sql
psql --dbname=lc --username=pgsql --quiet --file=$lcdir/tables/table-pending_purchases.sql
psql --dbname=lc --username=pgsql --quiet --file=$lcdir/tables/table-reminders.sql
psql --dbname=lc --username=pgsql --quiet --file=$lcdir/tables/table-reg_codes.sql
psql --dbname=lc --username=pgsql --quiet --file=$lcdir/tables/table-sessions.sql
psql --dbname=lc --username=pgsql --quiet --file=$lcdir/tables/table-member_apps.sql

echo 6/9 Installing Functions
for i in $lcdir/functions/func-*.sql; do
    psql --dbname=lc --username=pgsql --quiet --file=$i
done

echo 7/9 Installing Roles
for i in $lcdir/roles/role-*.sql; do
    psql --dbname=lc --username=pgsql --quiet --file=$i
done

echo 8/9 Running Setup Functions
## psql emits a blank line, grep eats it
psql -d lc -U pgsql -t -c 'select admin_create_itemtypes();' | grep '.'
psql -d lc -U pgsql -t -c 'select admin_create_categories();' | grep '.'
psql -d lc -U pgsql -t -c 'select admin_create_eventcodes();' | grep '.'
psql -d lc -U pgsql -t -c 'select admin_create_retvals();' | grep '.'
psql -d lc -U pgsql -t -c 'select admin_create_defaultfolders();' | grep '.'
psql -d lc -U pgsql -t -c 'select admin_create_forms();' | grep '.'
psql -d lc -U pgsql -t -c 'select admin_create_applist();' | grep '.'
psql -d lc -U pgsql -t -c 'select admin_create_admin_account();' | grep '.'
psql -d lc -U pgsql -t -c 'select admin_create_demo_account();' | grep '.'

echo 9/9 Installing Test Suite
for i in $lcdir/tests/*.pgsql; do
    psql --dbname=lc --username=pgsql --quiet --file=$i
done

echo Finished.
echo
