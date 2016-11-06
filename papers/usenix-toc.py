#!/usr/bin/python3

import re
import sys
import fileinput
if len(sys.argv) < 3:
  print("Generate: %s <toc-file> <page-shift>" % sys.argv[0])
  print("Export function: echo $(%s <toc-file> <page-shift>) | source /dev/stdin" % sys.argv[0])
  exit(0)

re_pn = re.compile(r'^.*\. ?(\d+)$')

shift=int(sys.argv[2])

i=100
pn=0
rec=[]
with fileinput.input(files=(sys.argv[1])) as f:
  for line in f:
    m = re_pn.match(line)
    if m is not None:
      i = 0
      pn = int(m.group(1))
    else:
      fa = line.split(',')[0].split(' and ')[0]
      if fa is not None:
        i = i + 1
        if i == 1:
          ln = fa.split(' ')[-1].lower()
          rec.append((pn, ln))

print("usenix_split()\n{")
head="  gs -sDEVICE=pdfwrite -dNOPAUSE -dBATCH -dSAFER -dNOPDFMARKS -dQUIET "
for i in range(0, len(rec) - 1):
  print("%s -dFirstPage=%d -dLastPage=%d -sOutputFile=p%d-%s.pdf ${1};" % (head, rec[i][0] + shift, rec[i+1][0] - 1 + shift, rec[i][0], rec[i][1]))

print("%s -dFirstPage=%d -sOutputFile=p%d-%s.pdf ${1};" % (head, rec[-1][0] + shift, rec[-1][0], rec[-1][1]))
print("}")
