
Directory Structure
-------------------

 crypto/     Support and wrapper functions for the pgcrypto library
 documents/  Text and documentation
 functions/  Data manipulation functions, the bulk of the code.
 roles/      Database user definitions (currently only "delphi")
 tables/     Database table definitions
 types/      Data type definitions, used to standardize interfaces
                across functions that return the same types of data
 transfer.sh Utility to place an installation package on a target machine via SCP.
 install.sh  Utility, meant to be run in the target location, which installs the database.
 update-functions.sh  Development utility which updates all of the database functions
                without restarting the database
                
Installation
------------

The LifeCloud database install requires a running installation of PostgreSQL
with the pgcrypto library installed.

1. Edit and run "transfer.sh" to copy the install package to your destination (it uses scp).
2. SSH to the destination directory and run "install.sh".
3. Done.
