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

# wget前に UniVec_Core, README.uv, UniVec を日付をつけてtmpに避難
rm -f ${FTP}/tmp/*
cd ${FTP}
if test -f ./UniVec/UniVec_Core
then
  # DATE=`ls -l --time-style=+%Y%m%d-%H%M UniVec_Core | sed -e 's/  */ /g'| cut -d " " -f6`
  # FNAME=`ls -l --time-style=+%Y%m%d-%H%M UniVec_Core | sed -e 's/  */ /g'| cut -d " " -f7`
  DATE=`ls -l --time-style=+%Y%m%d UniVec/UniVec_Core | sed -e 's/  */ /g'| cut -d " " -f6`
  cp -a ./UniVec/UniVec_Core ./tmp/${DATE}UniVec_Core
fi

if test -f ./UniVec/README.uv
then
  DATE=`ls -l --time-style=+%Y%m%d UniVec/README.uv | sed -e 's/  */ /g'| cut -d " " -f6`
  cp -a ./UniVec/README.uv ./tmp/${DATE}README.uv
fi

if test -f ./UniVec/UniVec
then
  DATE=`ls -l --time-style=+%Y%m%d UniVec/UniVec | sed -e 's/  */ /g'| cut -d " " -f6`
  cp -a ./UniVec/UniVec ./tmp/${DATE}UniVec
fi

## wget 実行, -np=no parent, -nd=no directory, -m=mirroring
rm -f ${DIR}/wgetmirror.log
wget -nH --cut-dirs=1 -m ftp://ftp.ncbi.nih.gov/pub/UniVec/ -o ${DIR}/wgetmirror.log
# -nH … ホスト名のディレクトリを作らない; --cut-dirs=1 ... pubディレクトリーまで作成しない

# README\.uv' *へ保存終了
if grep -P "README\.uv' saved" ${DIR}/wgetmirror.log >/dev/null 2>&1; then
  # tmpに避難したファイルがあればarchiveconstにmvする
  if test -f ./tmp/*README.uv; then
     mv ./tmp/*README.uv ./archiveconst/
  fi
  echo "`date +%Y%m%d`: README.uv (ver `ls -l --time-style=+%Y%m%d ./UniVec/README.uv | sed -e 's/  */ /g' | cut -d " " -f6`) was downloaded."
else
  rm ${FTP}/tmp/*README.uv
  echo "`date +%Y%m%d`: No need to update README.uv."
fi

# UniVec' *へ保存終了
if grep -P "UniVec' saved" ${DIR}/wgetmirror.log >/dev/null 2>&1; then
  # tmpに避難したファイルがあればarchiveconstにmvする
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

# UniVec_Core' *へ保存終了
cd ${FTP}
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
