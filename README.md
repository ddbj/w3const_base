# w3const_base
Common tools for w3const project

## bin/
Useful x64 binaries are placed here.

## Getblastdb_ncbi.sh
Download and decompress blastdb from NCBI.

Before using:
To run the script, you must confirm that jq and pigz binaries exist on ~/w3const_base/bin on the local disk. If the files are not existed, you must update the ~/w3const_base as follows.
~~~
cd ~/w3const_base
git pull
~~~
Usage:
Edit the variable 'BASE' in the script. The 'BASE' is your working directory.
~~~
cd ~/Working Directory
./Getblastdb_ncbi.sh
~~~

## sendgmail_w3const.py
Sends email from w3const@.

Requirement: > python3.6

Usage:
python3 sendgmail_w3const.py [-h] --sj subject --to email --body file [--cc email] [--bcc email] [--att file]

Prepare credential and white list files in advance.
1. Create a credential file to run the script.
~~~  
mkdir -m 700 ~/.sendgmail_w3const
echo 'GmailAccount:ApplicationPassword' > ~/.sendgmail_w3const/account
chmod 400 ~/.sendgmail_w3const/account
~~~
2. Create a whitelist
~~~
touch ~/.sendgmail_w3const/whitelist; chmod 600 ~/.sendgmail_w3const/whitelist
Write an email address to the whitelist in each line.
~~~
