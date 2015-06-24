#!/bin/bash

wgetopts="-q --keep-session-cookies --load-cookies /tmp/tmp-${USER}-cookies.txt --save-cookies /tmp/tmp-${USER}-cookies.txt"

get_pdf_by_id()
{
  id=$1
  pagefile=${id}.page
  pdffile=${id}.pdf
  if [[ -f $pdffile ]]; then
    echo pass ${pdffile}!
    return 0
  else
    pageurl="http://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=$id"
    wget $wgetopts $pageurl -O ${pagefile}
    pdfurl=$(grep arnumber ${pagefile} | sed -n -e 's/^.*src="\(.*\)".*$/\1/p')
    if [[ -n $pdfurl ]]; then
      echo download ${pdffile}!
      wget ${wgetopts} ${pdfurl} -O ${pdffile}
    fi
    rm ${pagefile}
  fi
}

# main
if [[ -n ${1} ]]; then
  get_pdf_by_id ${1}
else
  echo "usage $0 <arnumber>"
fi
