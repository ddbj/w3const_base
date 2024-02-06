#!/bin/bash
export PATH=/home/tkosuge-sys/jparser/:$PATH
cd /home/tkosuge-sys/DeasyCheckSubmission
# 上記ディレクトリ配下にdeasy ディレクトリを作っておくことが必要
# jParser が実行できるようにパスを通しておくこと

# 今日の日付を取得
# DAY=`date -d '1 days ago' +%Y%m%d`
DAY=`date +%Y%m%d`

# w3deasyとsynch
rsync -av --delete guanine:/home/w3deasy/submission/${DAY} ./deasy/

echo "DATE-TIME: $(date +%Y%m%d-%H%M%S)" > deasycheckResult.txt

COUNT=0
ERRCOUNT=0
FILE=`ls ./deasy/${DAY}/*.*`
NAME=($(for V in ${FILE[@]}; do echo ${V%.*}; done | sort -t'_' -k2,2 | uniq ))
#echo ${NAME[@]}

if [ ${NAME[0]} ]; then
for V in ${NAME[@]}; do
  COUNT=`expr ${COUNT} + 1`
  (echo "${COUNT}: ${V}" >> deasycheckResult.txt)
  (/home/tkosuge-sys/jparser/jParser.sh -x ${V}.ann -s ${V}.fasta 2>&1 | cat > _temp.txt)
  grep -P "^\w+\d+:ER1:|^\w+\d+:FAT:" _temp.txt
  if [ $? -eq 0 ]
  then
     echo "*FAILED*" | cat >> _temp.txt
     ERRCOUNT=`expr ${ERRCOUNT} + 1`
  else
     echo "*PASSED*" | cat >> _temp.txt
  fi
  cat _temp.txt >> deasycheckResult.txt
  echo "" >> deasycheckResult.txt
  rm -f _temp.txt
done
else
  (echo "${COUNT} submission" >> deasycheckResult.txt)
fi

# メール送信用perlに渡す
SUBJECT1="DeasyCheck:${COUNT}-sets(`date +%Y%m%d-%H%M`):PASSED"
SUBJECT2="DeasyCheck:${COUNT}-sets(`date +%Y%m%d-%H%M`):${ERRCOUNT}-FAILED"

if [ ${ERRCOUNT} -eq 0 ]
then
  perl ./SendEmail3.pl deasycheckResult.txt ${SUBJECT1}
else
  perl ./SendEmail3.pl deasycheckResult.txt ${SUBJECT2}
  perl ./SendEmail2.pl FailedMailbody.txt ${SUBJECT2}
fi

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
