#!/bin/bash
# Get blast db on NCBI according with metadata.json, and decompress them.
# Download the blast data file only When the metadata-json file is updated.
# If you want to download blast data regardless of the update date in metadata-json,
# erase the ftplog/*.json files before you run the script.

export LANG=C
# Blast databases having their own meta file.
DBNAME=("nr-prot" \
"nt-nucl" \
"nt_euk-nucl" \
"nt_prok-nucl" \
"nt_viruses-nucl" \
"nt_others-nucl" \
"16S_ribosomal_RNA-nucl" \
"18S_fungal_sequences-nucl" \
"28S_fungal_sequences-nucl" \
"LSU_eukaryote_rRNA-nucl" \
"LSU_prokaryote_rRNA-nucl" \
"SSU_eukaryote_rRNA-nucl" \
"human_genome-nucl" \
"ITS_eukaryote_sequences-nucl" \
"ITS_RefSeq_Fungi-nucl" \
"landmark-prot" \
"mouse_genome-nucl" \
"ref_euk_rep_genomes-nucl" \
"ref_prok_rep_genomes-nucl" \
"ref_viroids_rep_genomes-nucl" \
"ref_viruses_rep_genomes-nucl" \
"refseq_protein-prot" \
"refseq_rna-nucl" \
"refseq_select_prot-prot" \
"refseq_select_rna-nucl" \
"mito-nucl" \
"env_nr-prot" \
"env_nt-nucl" \
"pataa-prot" \
"patnt-nucl" \
"pdbaa-prot" \
"pdbnt-nucl" \
"tsa_nr-prot" \
"tsa_nt-nucl" \
"Betacoronavirus-nucl" \
"swissprot-prot" \
"taxdb")

# cdd_delta has no metadata. Probably update is very rare.
DBWOMETA=("cdd_delta")

MAXTRY=5
BASE="${HOME}/work-kosuge"
LOGDIR="${BASE}/log"
DBSRC="ftp://ftp.ncbi.nih.gov/blast/db"
DATLOC="${BASE}/ftpbldb-work"
DATLOCF="${BASE}/ftpbldb-keep"
JSONLOC="${BASE}/ftpbldb-json"
BDB="${BASE}/blastdbv5"
DBJSHR="/home/ddbjshare/blast/db/v5"
NEWDAT=()

if [ ! -e ${BASE} ] ; then
echo "You need to prepare ${BASE} directory before running."
exit 1
fi
which ascp
if [ $? -eq 1 ] ; then
echo "You need to install IBM aspera connect to your home."
exit 1
fi

mkdir -p -m 775 ${DATLOC}
mkdir -p -m 775 ${DATLOCF}
mkdir -p -m 775 ${JSONLOC}
mkdir -p -m 775 ${JSONLOC}/tmp
mkdir -p -m 775 ${BDB}
export PATH=${HOME}/.aspera/connect/bin:$PATH

# Download json metadata and blast data
getjsondb() {
    # curl -s -o ${JSONLOC}/${v}-metadata.json ${DBSRC}/${v}-metadata.json
    mv -f ${JSONLOC}/tmp/${v}-metadata.json ${JSONLOC}/
    DBN=$(cat ${JSONLOC}/${v}-metadata.json | jq -r '."dbname"')
    NEWDAT+=("$DBN")
    FNUM=$(cat ${JSONLOC}/${v}-metadata.json | jq -r '."files" | length')
    cd $DATLOC
    # 
    for i in `seq 0 $(( $FNUM - 1 ))`;do
    FURL=$(cat ${JSONLOC}/${v}-metadata.json | jq -r '."files"['$i']')
    FNAME=${FURL/ftp:\/\/ftp.ncbi.nlm.nih.gov\/blast\/db\/}
    # echo $FURL
    # At the beginning, delete former targz,md5
    [ $i -eq 0 ] && rm -f ${DATLOC}/${FNAME%%.*}.*
    curl -s --retry 5 -O $FURL.md5
    if [ -e "${FNAME}.md5" ]; then
      CNT=1
    else
      CNT=$(($MAXTRY+1))
      FCHK="BAD"
    fi
    while [ "$CNT" -le "$MAXTRY" ]; do
      FCHK=""
      # ascp -i ~/.aspera/connect/etc/asperaweb_id_dsa.openssh -T -k1 -l800m anonftp@ftp.ncbi.nlm.nih.gov:blast/db/${FNAME} ./
      # ascp -i /opt/aspera/connect/etc/asperaweb_id_dsa.openssh -T -k1 -l400m anonftp@ftp.ncbi.nlm.nih.gov:blast/db/${FNAME} ./
      wget -q -T 60 -t 2 --waitretry=30 $FURL
      # wget -q -P ${DATLOC} -T 60 -t 3 --waitretry=30 $FURL
      # wget -q -P ${DATLOC} -T 60 -t 3 --waitretry=30 $FURL.md5
      FCHK=$(md5sum -c $FNAME.md5 | grep -o "OK")
      if [ "$FCHK" = "OK" ]; then
        echo "$(date +%Y%m%d-%H%M): $FNAME is good"
        CNT=$(($MAXTRY+1))
      else
        echo "#$CNT times tried, $FNAME is wrong."
        CNT=$(($CNT+1))
        FCHK="BAD"
        rm -f ${DATLOC}/${FNAME}
        rm -f ${DATLOC}/${FNAME}.md5
      fi
      sleep 3
    done
    # read -p "Continue?"
    if [ "$FCHK" != "OK" ]; then
      echo "$FNAME is broken. Stop the downloading of ${v} and use the former data set."
      rm -f ${DATLOC}/${FNAME%%.*}.*
      cp -av ${DATLOCF}/${FNAME%%.*}.* ${DATLOC}/
      # break for
      break
    fi
    sleep 3
    done
} 

decompress() {
  for v in "${NEWDAT[@]}"; do
  rm -f ${BDB}/${v}.*
  for targz in ${DATLOC}/${v}*.tar.gz; do
  tar xvf ${targz} -C ${BDB}/ --use-compress-program="pigz"
  done
  done
  # The taxdb should be decompressed again at the end of the function.
  for targz in ${DATLOC}/taxdb*.tar.gz; do
  tar xvf ${targz} -C ${BDB}/ --use-compress-program="pigz"
  done
}

keepdat() {
  rsync -av --delete ${DATLOC}/ ${DATLOCF}/
}

syncdbjshare() {
  rsync -av --delete ${BDB}/ ${DBJSHR}/
}

# Main
c=0
for v in ${DBNAME[@]}; do
CHKARUYO=0
if [ -e "${JSONLOC}/${v}-metadata.json" ];then
  # echo "Aruyo!"
  FORMER=$(cat ${JSONLOC}/${v}-metadata.json | jq -r '."last-updated"')
  curl -s --retry 5 -o ${JSONLOC}/tmp/${v}-metadata.json ${DBSRC}/${v}-metadata.json
  LATEST=$(cat ${JSONLOC}/tmp/${v}-metadata.json | jq -r '."last-updated"')
  # LATEST=$(curl -s ${DBSRC}/${v}-metadata.json | jq -r '."last-updated"')
  # Try one more if curl is failed.
  if [ -z "$LATEST" ]; then
    sleep 10
    curl -s --retry 5 -o ${JSONLOC}/tmp/${v}-metadata.json ${DBSRC}/${v}-metadata.json
    LATEST=$(cat ${JSONLOC}/tmp/${v}-metadata.json | jq -r '."last-updated"')
  fi
  # If curl is failed, let LATEST has blank not to start the downloading.
  [ -z "$LATEST" ] && LATEST="0000-00-00T00:00:00"
  echo $FORMER
  echo $LATEST
  if [[ "$FORMER" > "$LATEST" ]] || [[ "$FORMER" == "$LATEST" ]]; then
    echo "${v}, no need to update."
    CHKARUYO=1
  else
    # Get data
    echo "${v}, needs update."
    c=2
    getjsondb
  fi
  if [ "${v}" = "Betacoronavirus-nucl" ] || [ "${v}" = "taxdb" ]; then
    if [ ${CHKARUYO} -eq 1 ]; then
      echo "${v} is exceptinal db. The date in the metadata is ${LATEST}, but needs update."
      getjsondb
      c=4
    fi
  fi
else
  # Get data, decompress
  echo "${v}, is downloading for the first time."
  c=1
  curl -s --retry 5 -o ${JSONLOC}/tmp/${v}-metadata.json ${DBSRC}/${v}-metadata.json
  getjsondb
fi
done

# CDD (no metadata)
cddmirror() {
  wget -o ${JSONLOC}/${v}.log -m -nd -w 10 -t 5 -P ${DATLOC} ${DBSRC}/${v}.tar.gz.md5
  wget -m -nd -w 10 -t 5 -P ${DATLOC} ${DBSRC}/${v}.tar.gz
  rm -f ${DATLOC}/.listing
}

for v in ${DBWOMETA[@]}; do
NEWCDD=0
echo $v
if [ ! -e ${JSONLOC}/${v}.log ]; then
  rm -f ${DATLOC}/${v}.*
  cddmirror
  NEWCDD=1
else
  cddmirror
fi
# Check md5 for cdd
CNT=1
cd ${DATLOC}
while [ "${CNT}" -le "${MAXTRY}" ]; do
  FCHK=$(md5sum -c ${v}.tar.gz.md5 | grep -o "OK")
  if [ "$FCHK" = "OK" ]; then
    echo "CDD is good."
    CNT=$(($MAXTRY+2))
  elif [ "${CNT}" -lt "${MAXTRY}" ]; then
    rm -f ${DATLOC}/${v}.*
    cddmirror
  else
    rm -f ${DATLOC}/${v}.*
    cp -av ${DATLOCF}/${v}.* ${DATLOC}/
  fi
  CNT=$(($CNT+1))
done
# Newly saved or not?
if [ $NEWCDD -eq 1 ]; then
  NEWDAT+=($v)
  c=3
elif grep -P "cdd_delta\.tar\.gz\.md5' saved" ${JSONLOC}/${v}.log >/dev/null 2>&1; then
  NEWDAT+=($v)
  c=3
else
  echo ${v} is already latest.
fi
done
# 
echo "$(date +%Y%m%d-%H%M): Downloading has been finished."
echo "$(date +%Y%m%d-%H%M): Updates are; ${NEWDAT[@]}"

# Decompress the tar.gz from ftp only when a new file has been obtained.
if [ $c -gt 0 ]; then
  decompress
fi
echo "$(date +%Y%m%d-%H%M): Decompression has been finished."

# Keep the good data
echo "-------------------------"
echo "$(date +%Y%m%d-%H%M): Started synchronization to keep the good data."
keepdat

# Sync to ddbjshare directory
echo "-------------------------"
echo "$(date +%Y%m%d-%H%M): Started synchronization to ddbjshare."
syncdbjshare

# Delete the temporal file
rm -rf ${JSONLOC}/tmp
