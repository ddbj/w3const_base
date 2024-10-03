# w3const_base
Common tools for w3const project

# How to build the container
~~~
cd ~
git clone https://github.com/ddbj/w3const_base.git
sudo singularity build constbase.sif ~/w3const_base/Singularity
~~~

***curatortool* directory contains the following scripts and binaries.**

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
Sends email by using the google account. You can specify a sender address if you have set the other email address(es) (e.g. sender alias) on the account.

Usage:
~~~
singularity exec /home/w3const/work-kosuge/constbase.sif sendgmail_w3const.py [-h] --sj subject --to email --body file [--cc email] [--bcc email] [--att file] [--sender address]
~~~

You must prepare credential and white list files in advance.
1. Create a credential file to run the script.
~~~  
mkdir -m 700 ~/.sendgmail_w3const
echo 'GmailAccount:ApplicationPassword' > ~/.sendgmail_w3const/account
chmod 600 ~/.sendgmail_w3const/account
~~~
2. Create a whitelist
~~~
touch ~/.sendgmail_w3const/whitelist; chmod 600 ~/.sendgmail_w3const/whitelist
Write an email address to the whitelist in each line.
~~~

3. Example
~~~
cd /home/w3const
singularity exec /home/w3const/work-kosuge/constbase.sif sendgmail_w3const.py --sj "てすとです" --to addr1,addr2 --body /home/w3const/work-kosuge/emailbody.txt
~~~

## makeUniVec_blastdb.sh
Download the UniVec fasta from NCBI and replace the local file with newwer ones. The script also prepares blast databases whose names are UniVec and UniVec_Core.

### Before use
Edit the directory name of BASE (line 8). It is used for base directory. You need to create "UniVec" directory under the base directory. The blast databases for UniVec and UniVec_Core are created to the directory designated by BLASTDIR (line 12).

Usage:
~~~
singularity exec /home/w3const/work-kosuge/constbase.sif makeUniVec_blastdb.sh
~~~

## splitff.sh
Separate a huge flatfile into small-sized flat files.

Usage
~~~
splitff.sh -f <flatfile> -s <number of lines>
~~~

## getorganismdivFF.py
Obtain or search taxnomyc division for a target entry from the flatfile, Entrez, or local taxonomy dump file. In the case of ENV or taxid=0, taxonomic division is obtained from Entrez search or tax dump file by using the beginning of the /organism as a query. 

Usage
~~~
e.g.1
getorganismdivFF.py  -i <flatfile> -a <accession num>
e.g.2
getorganismdivFF.py  -i <flatfile> -a <accession num> -p <tax dump directory>
~~~

## jParser & transChecker
https://ddbj.nig.ac.jp/public/ddbj-cib/MSS/

## blast & matrix
ftp://ftp.ncbi.nih.gov/blast/executables/blast+/
ftp://ftp.ncbi.nih.gov/blast/matrices

## vecscrnfilter.py

Reads vecscreen result that carried out with options -outfmt 0 -text_output, and filter the results with the degree of blast matches.

Usage
~~~
vecscrnfilter.py [-s|-m|-w] [alignment file]
#  '-s' outputs only 'Strong match'
#  '-m' outputs 'Moderate match' & 'Strong Match'
#  '-w' outputs 'Weak match' besides 'Moderate match' & 'Strong match'
#  They may contain 'Suspect origin' if included in the result
~~~

## SRA Toolkit
Latest version of https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/

## Aspera Connect
https://www.ibm.com/aspera/connect/

