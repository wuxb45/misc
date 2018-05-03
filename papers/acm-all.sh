#!/bin/bash

#wgetopts="-q -U 'Mozilla/5.0 (Windows NT 5.1; rv:10.0.2) Gecko/20100101 Firefox/10.0.2' --keep-session-cookies --load-cookies /tmp/tmp-${UESR}-cookies.txt --save-cookies /tmp/tmp-${USER}-cookies.txt"
wgetopts="-q -U 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_4) AppleWebKit/600.7.12 (KHTML, like Gecko) Version/8.0.7 Safari/600.7.12' --keep-session-cookies --load-cookies /tmp/tmp-${UESR}-cookies.txt --save-cookies /tmp/tmp-${USER}-cookies.txt"

get_acm_pdf_by_id()
{
  id=${1}
  pagefile=${id}.page
  pdffile=${id}.pdf
  if [[ -f $pdffile ]]; then
    echo pass ${pdffile}!
    return 0
  else
    pageurl="http://dl.acm.org/citation.cfm?id=$id"
    wget $wgetopts $pageurl -O ${pagefile}
    suffix=$(grep 'ft_gateway' ${pagefile} | sed -n -e 's/^.*href="\(.*\)" target.*$/\1/p')
    if [[ -n $suffix ]]; then
      pdfurl="http://dl.acm.org/${suffix}"
      echo "download ${pdffile} ${pdfurl}"
      wget ${wgetopts} "${pdfurl}" -O ${pdffile}
    fi
    rm ${pagefile}
  fi
  sleep 10
}

get_all()
{
  tocid=${1}
  tocfile=${tocid}.toc
  ids=${tocid}.ids
  tocurl="https://dl.acm.org/citation.cfm?id=${1}&preflayout=flat"
  wget $wgetopts $tocurl -O ${tocfile}
  cat ${tocfile} | tr ' ' '\n' | grep 'ft_gateway.cfm?id' | sed -e 's/^.*cfm?id=\([0-9][0-9]*\)\&.*$/\1/' >${ids}
  for id in $(cat ${ids}); do
    get_acm_pdf_by_id ${id}
  done
}

# main
if [[ $# -eq 0 ]]; then
  echo "Usage $0 <toc-page-id>"
else
  get_all ${1}
fi
