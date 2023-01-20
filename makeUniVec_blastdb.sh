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
export LANG=C

if [ ! -e ${BASE} ] || [ ! -e ${DIR} ] || [ ! -e ${BLASTDIR} ]; then
echo "You need to prepare ${BASE}, ${DIR}, and ${BLASTDIR} directories to run."
exit 1
fi

mkdir -p ${FTP}
mkdir -p ${FTP}/archive
mkdir -p ${FTP}/tmp

# wget前に UniVec_Core, README.uv, UniVec を日付をつけてtmpに避難
rm -f ${FTP}/tmp/*
cd ${FTP}
if test -f ./UniVec_Core
then
  # DATE=`ls -l --time-style=+%Y%m%d-%H%M UniVec_Core | sed -e 's/  */ /g'| cut -d " " -f6`
  # FNAME=`ls -l --time-style=+%Y%m%d-%H%M UniVec_Core | sed -e 's/  */ /g'| cut -d " " -f7`
  DATE=`ls -l --time-style=+%Y%m%d UniVec_Core | sed -e 's/  */ /g'| cut -d " " -f6`
  cp -a ./UniVec_Core ./tmp/${DATE}UniVec_Core
fi

if test -f ./README.uv
then
  DATE=`ls -l --time-style=+%Y%m%d README.uv | sed -e 's/  */ /g'| cut -d " " -f6`
  cp -a ./README.uv ./tmp/${DATE}README.uv
fi

if test -f ./UniVec
then
  DATE=`ls -l --time-style=+%Y%m%d UniVec | sed -e 's/  */ /g'| cut -d " " -f6`
  cp -a ./UniVec ./tmp/${DATE}UniVec
fi

## wget 実行, -np=no parent, -nd=no directory, -m=mirroring
rm -f ${DIR}/wgetmirror.log
wget -np -nd -m ftp://ftp.ncbi.nih.gov/pub/UniVec/ -o ${DIR}/wgetmirror.log

# README\.uv' *へ保存終了
if grep -P "README\.uv' saved" ${DIR}/wgetmirror.log >/dev/null 2>&1; then
  # tmpに避難したファイルがあればarchiveにmvする
  if test -f ./tmp/*README.uv; then
     mv ./tmp/*README.uv ./archive/
  fi
  echo "`date +%Y%m%d`: README.uv (ver `ls -l --time-style=+%Y%m%d ./README.uv | sed -e 's/  */ /g' | cut -d " " -f6`) was downloaded."
else
  rm ./tmp/*README.uv
  echo "`date +%Y%m%d`: No need to update README.uv."
fi

# UniVec' *へ保存終了
if grep -P "UniVec' saved" ${DIR}/wgetmirror.log >/dev/null 2>&1; then
  # tmpに避難したファイルがあればarchiveにmvする
  if test -f ./tmp/*UniVec; then
     mv ./tmp/*UniVec ./archive/
  fi
  cp -a ./UniVec ${BLASTDIR}/
  cd ${BLASTDIR}/
  D_UNIVEC=`ls -l --time-style=+%Y%m%d ./UniVec | sed -e 's/  */ /g' | cut -d " " -f6`
  makeblastdb -in UniVec -dbtype nucl -input_type fasta -title "NCBI UniVec (ver ${D_UNIVEC})" -parse_seqids -out UniVec >> ${DIR}/makeblast_univec.log
  cd ${FTP}
  echo "`date +%Y%m%d`: UniVec (ver ${D_UNIVEC}) was downloaded. UniVec blastdb is updated."
else
  rm ./tmp/*UniVec
  echo "`date +%Y%m%d`: No need to update UniVec."
fi

# UniVec_Core' *へ保存終了
if grep -P "UniVec_Core' saved" ${DIR}/wgetmirror.log >/dev/null 2>&1; then
  # tmpに避難したファイルがあればarchiveにmvする
  if test -f ./tmp/*UniVec_Core; then
     mv ./tmp/*UniVec_Core ./archive/
  fi
  cp -a ./UniVec_Core ${BLASTDIR}/
  cd ${BLASTDIR}/
  D_UNIVECCORE=`ls -l --time-style=+%Y%m%d ./UniVec_Core | sed -e 's/  */ /g' | cut -d " " -f6`
  makeblastdb -in UniVec_Core -dbtype nucl -input_type fasta -title "NCBI UniVec_Core (ver ${D_UNIVECCORE})" -parse_seqids -out UniVec_Core >> ${DIR}/makeblast_univeccore.log
  cd ${FTP}
  echo "`date +%Y%m%d`: UniVec_Core (ver ${D_UNIVECCORE}) was downloaded. UniVec_Core blastdb is updated."
else
  rm ./tmp/*UniVec_Core
  echo "`date +%Y%m%d`: No need to update UniVec_Core."
fi
