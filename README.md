# w3const_base
Common tools for w3const project

# How to build the container
~~~
cd ~
git clone https://github.com/ddbj/w3const_base.git
sudo singularity build constbase.sif ~/w3const_base/Singularity
~~~

**The container includes the following scripts.**

## getblastdb_ncbi.sh
Download blast/db data from NCBI by using aspera connect and decompress to the blastdb directory.

Usage:
~~~
singularity exec /home/w3const/work-kosuge/constbase.sif getblastdb_ncbi.sh
~~~

Variables:

* DBNAME ... blast db to be downloaded.
* MAXTRY ... Retry download until the times, when a downloaded file is broken.
* BASE ... Base directory for running the script.
* DBSRC ... URL of NCBI data resource.
* DATLOC ... Usually, the latest tar.gz archives from NCBI are placed. When the downloading was failed, the tar.gz files are copied from DATLOCF directory.
* DATLOCF ... Former tar.gz archives from NCBI are placed.
* JSONLOC ... Manifest json files from NCBI. Each file are downloaded based on the information in the json file.
* BDB ... A directory where decompressed data are placed.

## sendgmail_w3const.py
Sends email by using the w3const@ google account.

Usage:
~~~
singularity exec /home/w3const/work-kosuge/constbase.sif sendgmail_w3const.py [-h] --sj subject --to email --body file [--cc email] [--bcc email] [--att file]
~~~

You must prepare credential and white list files in advance.
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

## makeUniVec_blastdb.sh
Download the UniVec from NCBI and create the blast database.

Usage:
~~~
singularity exec /home/w3const/work-kosuge/constbase.sif makeUniVec_blastdb.sh
~~~