#!/bin/sh

## ------------------------------------------------------------------
##  transfer.sh
## ------------------------------------------------------------------
##  Transfers a LifeCloud PostgreSQL Database installation package
##      using an scp (ssh cp) connection string.
##  You are prompted for the user's login password.
## ------------------------------------------------------------------
##  To finish installation, restart PostgreSQL on the target machine
##      to remove any connected users, then run install.sh
## ------------------------------------------------------------------

# DEVELOPMENT
# target=dbrown@CypressBSD:/home/dbrown/lc

# PRODUCTION 27349srwhe
target=pgsql@70.99.204.141:/usr/local/pgsql/lifecloud_src

echo # Remove Mac garbage files
rm -f .DS_Store
rm -f crypto/.DS_Store
rm -f documents/.DS_Store
rm -f functions/.DS_Store
rm -f roles/.DS_Store
rm -f types/.DS_Store
rm -f tables/.DS_Store

echo Connecting to $target ...
echo
scp -r -P 4422 install.sh crypto functions roles tables types README.txt $target

echo Done.
echo

