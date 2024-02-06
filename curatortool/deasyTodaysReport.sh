#!/bin/bash
BASEDIR="/home/systool/DeasyCheckSubmission"
PARSERDIR="/home/systool/jparser"
export PATH=/home/systool/jparser/:$PATH

cd ${BASEDIR}
# 上記ディレクトリ配下にdeasy ディレクトリを作っておくことが必要

# 0:10に実行、前日の日付を取得
DAY=`date -d '1 days ago' +%Y%m%d`

# w3deasyとsynch
rsync -a --delete scgw:/home/w3deasy/submission/${DAY} ./deasy/

COUNT=0
ERRCOUNT=0
# file name取得、拡張子とる、ソート
FILE=`ls ./deasy/${DAY}/*.*`
NAME=($(for V in ${FILE[@]}; do echo ${V%.*}; done | sort -t'_' -k2,2 | uniq ))

# 表作成
echo "D-easy Submissions on ${DAY}" > deasyTodaysResult.txt
echo -e "./deasy/${DAY}\t$(cat ./deasy/${DAY}/*.fasta | grep -c '>') entries (${#NAME[@]} sets)" >> deasyTodaysResult.txt
echo "-----------------------------------------------------" >> deasyTodaysResult.txt
#echo ${NAME[@]}
for V in ${NAME[@]}; do
 echo -e "${V##*/}\t$(grep -c '>' ${V}.fasta)" >> deasyTodaysResult.txt
done
echo -e "-----------------------------------------------------\n" >> deasyTodaysResult.txt

# 各submissionのjParser
if [ ${NAME[0]} ]; then
for V in ${NAME[@]}; do
  COUNT=`expr ${COUNT} + 1`
  (echo "${COUNT}: ${V##*/}" >> deasyTodaysResult.txt)
  (${PARSERDIR}/jParser.sh -x ${V}.ann -s ${V}.fasta 2>&1 | cat > _temp.txt)
  grep -P "^\w+\d+:ER1:|^\w+\d+:FAT:" _temp.txt
  if [ $? -eq 0 ]
  then
     echo "*FAILED*" | cat >> _temp.txt
     ERRCOUNT=`expr ${ERRCOUNT} + 1`
  else
     echo "*PASSED*" | cat >> _temp.txt
  fi
  cat _temp.txt >> deasyTodaysResult.txt
  echo "" >> deasyTodaysResult.txt
  rm -f _temp.txt
done
else
  (echo "${COUNT} submission" >> deasyTodaysResult.txt)
fi

# メール送信用perlに渡す
SUBJECT1="DeasyReport(${DAY}):${COUNT}-sets:PASSED"
SUBJECT2="DeasyReport(${DAY}):${COUNT}-sets:${ERRCOUNT}-FAILED"

if [ ${ERRCOUNT} -eq 0 ]
then
  perl ./SendEmail3.pl deasyTodaysResult.txt ${SUBJECT1}
else
  perl ./SendEmail3.pl deasyTodaysResult.txt ${SUBJECT2}
fi

# Delete old directory
find ${BASEDIR}/deasy -type d -mtime +30 -exec rm -rf {} +

## おまけ既存の日付フォルダを探して削除する
## ls /home/tkosuge/DeasyFile/ | grep -P "\d\d\d\d\d\d\d\d"
## st=$?
## echo "$st # 1=no directory 0=directory has existed"
## if test $st -eq 0
##  then
##  for var in `ls /home/tkosuge/DeasyFile/ | grep -P "\d\d\d\d\d\d\d\d"`
##   do
##   rm -rf /home/tkosuge/DeasyFile/${var}
##   echo -e "`date +%Y%m%d-%T`: ${var} deleted" >> /home/tkosuge/DeasyFile/log.txt
##  done
##  else
##   echo -e "`date +%Y%m%d-%T`: no directory deleted" >> /home/tkosuge/DeasyFile/log.txt
## fi
## 
## #昨日の日付をYYYYMMDDのフォーマットで取得してフォルダ作成
## today=`date -d '1 days ago' +%Y%m%d`
## echo -e "`date +%Y%m%d-%T`: ${today} created" >> /home/tkosuge/DeasyFile/log.txt
## mkdir /home/tkosuge/DeasyFile/${today}
## 
## #作成したフォルダ内に、/home/tkosuge/reportSakura2DB/からコピー
## `cp /home/tkosuge/reportSakura2DB/${today}/* /home/tkosuge/DeasyFile/${today}/`
#
