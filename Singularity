Bootstrap: library
From: ubuntu:22.04
Stage: build

# path, BLASTMAT (blast matrices)
%environment
    export PATH=/opt/w3constbin:/opt/jParser:/opt/transChecker:/opt/ncbi-blast-2.13.0+/bin:$PATH
    export BLASTMAT=/opt/blastmatrix
    export LANG=en_US.UTF-8

%files
    sendgmail_w3const.py /opt
    getblastdb_ncbi.sh /opt
    makeUniVec_blastdb.sh /opt

%runscript

%post
    sed -i.bak -e 's%deb http://archive.ubuntu.com%deb http://linux.yz.yamagata-u.ac.jp%g' /etc/apt/sources.list
    sed -i.bak -e 's%deb http://security.ubuntu.com%deb http://linux.yz.yamagata-u.ac.jp%g' /etc/apt/sources.list
    apt update
    apt -y upgrade
    apt -y install tzdata
    echo Asia/Tokyo > /etc/timezone
    dpkg-reconfigure --frontend noninteractive tzdata
    apt -y install build-essential
    apt -y install autoconf bison libssl-dev libyaml-dev libreadline-dev zlib1g-dev libncurses-dev libffi-dev libgdm1 libgdbm-dev git
    apt -y install wget curl jq pigz lftp rsync
    apt -y install openjdk-17-jre
    # Put base scripts
    mkdir /opt/w3constbin
    mv /opt/*.sh /opt/*.py /opt/w3constbin
    chmod +x /opt/w3constbin/*.sh /opt/w3constbin/*.py
    # Parser, transchecker
    wget https://ddbj.nig.ac.jp/public/ddbj-cib/MSS/Parser_V6.69.tar.gz -O /opt/jparser.tar.gz
    wget https://ddbj.nig.ac.jp/public/ddbj-cib/MSS/transChecker_V2.22.tar.gz -O /opt/transChecker.tar.gz
    cd /opt
    for v in /opt/*.tar.gz; do
    tar xvfz $v
    done
    rm -f jparser.tar.gz transChecker.tar.gz
    sed -i -e 's%PARSER_DIR=./%PARSER_DIR=/opt/jParser%' ./jParser/jParser.sh
    sed -i -e 's%TRANS_DIR=./%TRANS_DIR=/opt/transChecker%' ./transChecker/transChecker.sh
    sed -i -e 's%HEAP_SIZE=128m%HEAP_SIZE=8192m%' ./jParser/jParser.sh ./transChecker/transChecker.sh
    chmod +x ./jParser/jParser.sh ./transChecker/transChecker.sh
    # blast bin
    wget ftp://ftp.ncbi.nih.gov/blast/executables/blast+/2.13.0/ncbi-blast-2.13.0+-x64-linux.tar.gz
    tar xvfz ncbi-blast-2.13.0+-x64-linux.tar.gz
    # blast matrix
    lftp -c "open -u anonymous,tkosuge@nig.ac.jp ftp.ncbi.nih.gov && mirror -v /blast/matrices /opt/blastmatrix && close && quit"

%labels
    Author tkosuge
    Version 1
