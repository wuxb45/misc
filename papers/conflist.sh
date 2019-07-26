#!/bin/bash
output="conflist.html"
rm -f ${output}
#USENIX (6)
#ATC 141 #OSDI 179
#NSDI 178 #FAST 146
#HotOS 155 #HotStorage 159
unames=(ATC OSDI NSDI FAST HotOS HotStorage)
uids=(131 179 178 146 155 159)
(
  echo "USENIX confs: "
for x in $(seq 0 5); do
  echo '<a href="https://www.usenix.org/conferences/byname/'${uids[$x]}'">'${unames[$x]}'</a>'
done
  echo "<br />"
) >>${output}

# some independent confs
(
  echo '
  Indes:
<a href="https://www.vldb.org/pvldb/index.html">PVLDB</a>
  <br />
  '
) >>${output}


# ACM
wgetopts="-q -U 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_4) AppleWebKit/600.7.12 (KHTML, like Gecko) Version/8.0.7 Safari/600.7.12' --keep-session-cookies --load-cookies /tmp/tmp-${UESR}-cookies.txt --save-cookies /tmp/tmp-${USER}-cookies.txt"

indexurl="https://dl.acm.org/proceedings.cfm"

# fetch today's list
wget ${wgetopts} ${indexurl} -O original.html

keys=(SOSP ASPLOS EuroSys "SoCC|SOCC" SIGMETRICS SIGMOD SYSTOR ISCA MICRO SC ICS HPDC PLDI POPL ICFP SIGCOMM ISMM PACT PODC SPAA VEE)
(
for key in ${keys[@]}; do
  egrep "\"${key}" original.html | head -n 6 | \
    sed -e 's/^.*id=\([0-9]*\)".*title="\(.*\)">.*<.a>.*$/<a href="https:\/\/dl.acm.org\/citation.cfm\?id=\1">\2<\/a>/'
  echo "<br />"
done
) >>${output}
