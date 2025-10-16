#!/bin/bash
## UniVecをみはって最新ならアップデート、旧ファイルをアーカイブ、同じなら何もしない
## 毎日cronで実行させる
## Created by tkosuge (2Oct 6, 2015)
#################################################################################

#このスクリプトのワーキング場(最後に / は不要)
BASE="$HOME/work-kosuge"
DIR="${BASE}/UniVec"
FTP="${DIR}/ftp"
#UniVec.fastaから作ったblastdbのディレクトリを指定
BLASTDIR="${BASE}/blastdb_univec"
BLASTV5="${BASE}/blastdbv5"
export LANG=C

if [ ! -e ${BASE} ] || [ ! -e ${DIR} ] || [ ! -e ${BLASTDIR} ]; then
echo "You need to prepare ${BASE}, ${DIR}, and ${BLASTDIR} directories to run."
exit 1
fi

mkdir -p ${FTP}
mkdir -p ${FTP}/archiveconst
mkdir -p ${FTP}/tmp

# wget前に UniVec_Core, UniVec を日付をつけてtmpに避難
rm -f ${FTP}/tmp/*
cd ${FTP}
if test -f ./UniVec/UniVec_Core
then
  # DATE=`ls -l --time-style=+%Y%m%d-%H%M UniVec_Core | sed -e 's/  */ /g'| cut -d " " -f6`
  # FNAME=`ls -l --time-style=+%Y%m%d-%H%M UniVec_Core | sed -e 's/  */ /g'| cut -d " " -f7`
  DATE=`ls -l --time-style=+%Y%m%d UniVec/UniVec_Core | sed -e 's/  */ /g'| cut -d " " -f6`
  cp -a ./UniVec/UniVec_Core ./tmp/${DATE}UniVec_Core
fi

if test -f ./UniVec/UniVec
then
  DATE=`ls -l --time-style=+%Y%m%d UniVec/UniVec | sed -e 's/  */ /g'| cut -d " " -f6`
  cp -a ./UniVec/UniVec ./tmp/${DATE}UniVec
fi

# README etc.
wget -m -nH --cut-dirs=1 https://ftp.ncbi.nih.gov/pub/UniVec/README.uv
wget -m -nH --cut-dirs=1 https://ftp.ncbi.nih.gov/pub/UniVec/README.vector.origins
wget -m -nH --cut-dirs=1 https://ftp.ncbi.nih.gov/pub/UniVec/artificial_intervals_5column.txt
wget -m -nH --cut-dirs=1 https://ftp.ncbi.nih.gov/pub/UniVec/artificial_whole_UniVec_entries.txt
wget -m -nH --cut-dirs=1 https://ftp.ncbi.nih.gov/pub/UniVec/biological_intervals_5column.txt

## wget UniVec実行, -np=no parent, -nd=no directory, -m=mirroring
rm -f ${DIR}/wgetmirror.log
# wget -nH --cut-dirs=1 -m ftp://ftp.ncbi.nih.gov/pub/UniVec/ -o ${DIR}/wgetmirror.log
wget -m -nH --cut-dirs=1 -o ${DIR}/wgetmirror.log https://ftp.ncbi.nih.gov/pub/UniVec/UniVec
# -nH … ホスト名のディレクトリを作らない; --cut-dirs=1 ... ディレクトリーまで作成しない

# UniVec' *へ保存終了
if grep -P "UniVec' saved" ${DIR}/wgetmirror.log >/dev/null 2>&1; then
  # tmpに避難したDATE付きのファイルをarchiveconstにmvする
  if test -f ./tmp/*UniVec; then
     mv ./tmp/*UniVec ./archiveconst/
  fi
  rm -f ${BLASTDIR}/UniVec ${BLASTDIR}/UniVec.*
  cp -a ./UniVec/UniVec ${BLASTDIR}/
  cd ${BLASTDIR}/
  D_UNIVEC=`ls -l --time-style=+%Y%m%d ./UniVec | sed -e 's/  */ /g' | cut -d " " -f6`
  makeblastdb -in UniVec -dbtype nucl -input_type fasta -title "NCBI UniVec (ver ${D_UNIVEC})" -parse_seqids -out UniVec >> ${DIR}/makeblast_univec.log
  
  echo "`date +%Y%m%d`: UniVec (ver ${D_UNIVEC}) was downloaded. UniVec blastdb is updated."
  rm -f ${BLASTV5}/UniVec ${BLASTV5}/UniVec.*
  cp -av UniVec UniVec.* ${BLASTV5}/
else
  rm ${FTP}/tmp/*UniVec
  echo "`date +%Y%m%d`: No need to update UniVec."
fi

# wget UniVec_Core
cd ${FTP}
wget -m -nH --cut-dirs=1 -o ${DIR}/wgetmirror.log https://ftp.ncbi.nih.gov/pub/UniVec/UniVec_Core
# UniVec_Core' *へ保存終了
if grep -P "UniVec_Core' saved" ${DIR}/wgetmirror.log >/dev/null 2>&1; then
  # tmpに避難したファイルがあればarchiveconstにmvする
  if test -f ./tmp/*UniVec_Core; then
     mv ./tmp/*UniVec_Core ./archiveconst/
  fi
  rm -f ${BLASTDIR}/UniVec_Core ${BLASTDIR}/UniVec_Core.*
  cp -a ./UniVec/UniVec_Core ${BLASTDIR}/
  cd ${BLASTDIR}/
  D_UNIVECCORE=`ls -l --time-style=+%Y%m%d ./UniVec_Core | sed -e 's/  */ /g' | cut -d " " -f6`
  makeblastdb -in UniVec_Core -dbtype nucl -input_type fasta -title "NCBI UniVec_Core (ver ${D_UNIVECCORE})" -parse_seqids -out UniVec_Core >> ${DIR}/makeblast_univeccore.log
  
  echo "`date +%Y%m%d`: UniVec_Core (ver ${D_UNIVECCORE}) was downloaded. UniVec_Core blastdb is updated."
  rm -f ${BLASTV5}/UniVec_Core ${BLASTV5}/UniVec_Core.*
  cp -av UniVec_Core UniVec_Core.* ${BLASTV5}/
else
  rm ${FTP}/tmp/*UniVec_Core
  echo "`date +%Y%m%d`: No need to update UniVec_Core."
fi
