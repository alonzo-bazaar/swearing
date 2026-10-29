#!/usr/bin/env python
import csv
import sys
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt

INPUT_FILE  = sys.argv[1] if len(sys.argv) > 1 else 'head.csv'
LANG_ROWS   = {}
FIELD_NAMES = None

with open('results.csv', 'r') as file:
    dr = csv.DictReader(file)
    lines = [row['codeLines'] for row in dr]

lines = np.asarray(lines, dtype=np.uint64)
hist, edges = np.histogram(lines, bins=100)
plt.bar(np.arange(len(hist)), hist)
plt.yscale('log')
plt.show()

with open('results.csv', 'r') as file:
    dr = csv.DictReader(file)
    for row in dr:
        # this if prints nothing
        # linux on github is a mirror, so it's not in our dataset
        if row['name'] == 'torvalds/linux':
            print(f'linux codeLines: {row['codeLines']}')
        # whereas this one, this one prints something
        if row['name'] == 'apache/httpd':
            print(f'httpd codeLines: {row['codeLines']}')
