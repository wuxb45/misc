#!/bin/bash

wgetopts="-q --keep-session-cookies --load-cookies /tmp/tmp-${USER}-cookies.txt --save-cookies /tmp/tmp-${USER}-cookies.txt"

# > ids
get_ids_of_page()
{
  url="$1"
  wget $wgetopts "$url" -O base.page
  grep "PDF" base.page | sed -n -e 's/^.*arnumber=\([0-9]*\).*$/\1/p' >> ids
}

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
if [[ $1 ]]; then
  echo get ids!
  get_ids_of_page "$1"
else
  echo download them!
  for id in $(cat ids); do
    get_pdf_by_id $id
  done
fi
