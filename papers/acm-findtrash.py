#!/usr/bin/python3
import os
import sys
import re

re_acm = re.compile(r'^p(\d+)-.*pdf$')

path = '.'
if len(sys.argv) > 1:
  path = sys.argv[1]

nums = []
for fn in os.listdir(path):
  m = re_acm.match(fn)
  if m is not None:
    nums.append((fn, int(m.group(1))))

nums = sorted(nums, key=lambda x:x[1])
if len(nums) > 1:
  for i in range(0, len(nums) - 1):
    print("%-36s %2d" % (nums[i][0], nums[i+1][1] - nums[i][1]))
  print("%-36s ##" % (nums[-1][0]))
