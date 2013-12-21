
Directory Structure
-------------------

 crypto/     Support and wrapper functions for the pgcrypto library
 documents/  Text and documentation
 functions/  Data manipulation functions, the bulk of the code.
 roles/      Database user definitions (currently only "delphi")
 tables/     Database table definitions
 types/      Data type definitions, used to standardize interfaces
                across functions that return the same types of data
 transfer.sh Utility to place an install package on a target machine via SCP.
 install.sh  Utility, meant to be run in the target location, which installs
                the database.
 update-functions.sh  Development utility which updates all of the
                database functions without restarting the database

Getting the Install package
---------------------------

There are two ways to get the database installation package on the target machine:

 - The easier is: "git clone git@github.com:mojo-blues/lifecloud.git".
    You may need a username and password.  This will create a subdirectory
    called 'lifecloud' from your current directory, with the install pack
    therein.

 - The second:  Edit and run the script 'transfer.sh', which copies the
   installation package onto the target machine via scp (cp|ssh).

Installation
------------
You must have a running installation of PostgreSQL
    with the pgcrypto library installed.
You must know where PostgreSQL stores its data files and have rwx access there
You must have permission to run pg_ctl,
    which stops and restarts PostgreSQL to kick the web service users off
     -- required in order to drop and recreate the database

Once the installation package is in place, go to its 'lifecloud' directory
    and run ./install.sh.
