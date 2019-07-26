#!/bin/bash

#remove query string after ".pdf"
for file in *.pdf\?*; do
  mv "${file}" "${file%%\?*}"
done
