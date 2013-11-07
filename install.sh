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
## -----------------------------------------------------------------------------
## 2013-10-11 dbrown : Unrolled table loading loop -- the tables were being
##                     created in a sequence that caused dependency errors
## 2013-11-05 dbrown : removed pg_ctl, added ref_apps and admin_create_applist
## -----------------------------------------------------------------------------

lcdir=.
pgdatadir=/opt/pgsql/data/

echo
echo LifeCloud Database Installer

echo 1/8 Dropping old LifeCloud database
dropdb lc;

echo 2/8 Creating new LifeCloud database
createdb lc;

echo 3/8 Installing Crypto Functions
psql --dbname=lc --username=pgsql --quiet --file=$lcdir/crypto/pgcrypto.sql
for i in $lcdir/crypto/func-*.sql; do
    psql --dbname=lc --username=pgsql --quiet --file=$i
done

echo 4/8 installing Data Types
for i in $lcdir/types/type-*.sql; do
    psql --dbname=lc --username=pgsql --quiet --file=$i
done

echo 5/8 Installing Tables
psql --dbname=lc --username=pgsql --quiet --file=$lcdir/tables/table-pgpkeys.sql
psql --dbname=lc --username=pgsql --quiet --file=$lcdir/tables/table-ref_defaultfolders.sql
psql --dbname=lc --username=pgsql --quiet --file=$lcdir/tables/table-ref_eventcodes.sql
psql --dbname=lc --username=pgsql --quiet --file=$lcdir/tables/table-ref_apps.sql
psql --dbname=lc --username=pgsql --quiet --file=$lcdir/tables/table-accounts.sql
psql --dbname=lc --username=pgsql --quiet --file=$lcdir/tables/table-members.sql
psql --dbname=lc --username=pgsql --quiet --file=$lcdir/tables/table-events.sql
psql --dbname=lc --username=pgsql --quiet --file=$lcdir/tables/table-folders.sql
psql --dbname=lc --username=pgsql --quiet --file=$lcdir/tables/table-files.sql
psql --dbname=lc --username=pgsql --quiet --file=$lcdir/tables/table-profilepics.sql
psql --dbname=lc --username=pgsql --quiet --file=$lcdir/tables/table-sessions.sql
psql --dbname=lc --username=pgsql --quiet --file=$lcdir/tables/table-member_apps.sql

echo 6/8 Installing Functions
for i in $lcdir/functions/func-*.sql; do
    psql --dbname=lc --username=pgsql --quiet --file=$i
done

echo 7/8 Installing Roles
for i in $lcdir/roles/role-*.sql; do
    psql --dbname=lc --username=pgsql --quiet --file=$i
done

echo 8/8 Running Setup Functions
psql --dbname=lc --username=pgsql --command='select admin_create_eventcodes();' > /dev/null
psql --dbname=lc --username=pgsql --command='select admin_create_defaultfolders();' > /dev/null
psql --dbname=lc --username=pgsql --command='select admin_create_applist();' > /dev/null
psql --dbname=lc --username=pgsql --command='select admin_create_admin_account();' > /dev/null
psql --dbname=lc --username=pgsql --command='select admin_create_demo_account();' > /dev/null

echo Finished.
echo

