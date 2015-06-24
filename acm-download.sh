#!/bin/bash

wgetopts="-q -U 'Mozilla/5.0 (Windows NT 5.1; rv:10.0.2) Gecko/20100101 Firefox/10.0.2' --keep-session-cookies --load-cookies /tmp/tmp-${UESR}-cookies.txt --save-cookies /tmp/tmp-${USER}-cookies.txt"

get_acm_pdf_by_id()
{
  id=$1
  pagefile=${id}.page
  pdffile=${id}.pdf
  if [[ -f $pdffile ]]; then
    echo pass ${pdffile}!
    return 0
  else
    pageurl="http://dl.acm.org/citation.cfm?id=$id"
    wget $wgetopts $pageurl -O ${pagefile}
    pdfurl=$(grep 'ft_gateway' ${pagefile} | sed -n -e 's/^.*href="\(.*\)" target.*$/\1/p')
    if [[ -n $pdfurl ]]; then
      echo $pdfurl
      echo download ${pdffile}!
      wget ${wgetopts} "http://dl.acm.org/${pdfurl}" -O ${pdffile}
    fi
    rm ${pagefile}
  fi
}

# main
if [[ -n ${1} ]]; then
  get_acm_pdf_by_id ${1}
else
  echo "usage $0 <arnumber>"
fi
