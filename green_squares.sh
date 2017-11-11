#! /usr/local/bin/bash

# automate a bunch of bogus commits and backdate them to turn all the squares green...

if [[ "${#@}" -lt 2 ]]; then
  echo " ##"
  echo " #  Please add at least 2 args"
  echo " # "
  echo " #  usage:"
  echo " #   $ ./green_squares.sh <github username> <repo name> [create repo and push to github - leave blank if NO]"
  echo " ##"
  exit
fi

USERNAME="$1"
REPONAME="$2"

# create repo on github
DATA_OPTS="{ \"name\":\"$REPONAME\" }"
curl -i -X POST -u "$USERNAME" -d "$DATA_OPTS" https://api.github.com/user/repos > /dev/null

# scrape the date of last green square
ayearago=$(curl https://github.com/vipyne |grep -m1 data-date= |sed -e 's/^.*date="//p')
echo "ayearago"
echo ayearago

rm -rf unixtime
rm -rf .git

git init
git add .
git commit -m "initial commit of the script responsible for drawing pictures with green squares"

STRING="1111111111111111111111111111199911199999111999991119999919999919999911199911111111111111111111111111111119999999111111911111191111119111111199999991111111911111191111119999999911111191111111111111911111191111119999999911111191111111111111999999911111191111119111111911111111191111119111911991911199991199991199991111999911119999111991911191119119111111111111111111"

year="${ayearago:0:4}"
day="${ayearago:8:2}"
month="${ayearago:5:2}"

case $month in
01)
  monthstr="Jan"
  ;;
02)
  monthstr="Feb"
  ;;
03)
  monthstr="Mar"
  ;;
04)
  monthstr="Apr"
  ;;
05)
  monthstr="May"
  ;;
06)
  monthstr="Jun"
  ;;
07)
  monthstr="Jul"
  ;;
08)
  monthstr="Aug"
  ;;
09)
  monthstr="Sep"
  ;;
10)
  monthstr="Oct"
  ;;
11)
  monthstr="Nov"
  ;;
12)
  monthstr="Dec"
  ;;
esac

UNIXTIMEAYEARAGO=$(date -j -f "%b %d %Y %T" "${monthstr} ${day} ${year} 12:00:00" "+%s")
# #UNIXTIMERIGHTNOW=$(date -j -f "%a %b %d %T %Z %Y" "`date`" "+%s")
# #                   $ date -j -f "%b %d %Y %T" "Apr 05 2016 00:00:00" "+%s"
UNIXTIME=$UNIXTIMEAYEARAGO

mkdir unixtime
cd unixtime || exit

for i in $(seq 1 ${#STRING}); do
  INNERLOOP="${STRING:i-1:1}"
  for j in $( seq 1 $(("$INNERLOOP" * 4)) ); do
    touch "$i-$j-unixtime"
    git add .
    git commit -m "commit number $i : $j"
    COMMITTIME=$(("$UNIXTIME" + "$j" * 10))
    git commit --amend --no-edit --date "$COMMITTIME"
    wait
  done
  wait
# 86400 seconds in a day
  UNIXTIME=$(("$UNIXTIME" + 86400))
done > /dev/null

git remote add origin git@github.com:vipyne/"$REPONAME".git
git push -u origin master

wait
open "https://github.com/"$USERNAME"
echo 'done'


# http://vipyne.tumblr.com/post/155636272150/insert-back-to-the-future-joke-here

