#!/usr/bin/env python
import csv
import sys

INPUT_FILE  = sys.argv[1] if len(sys.argv) > 1 else 'head.csv'
LANG_ROWS   = {}
FIELD_NAMES = None

with open(INPUT_FILE, 'r') as file:
    dr = csv.DictReader(file)
    FIELD_NAMES = dr.fieldnames
    for row in dr:
        ml = row['mainLanguage']
        if ml not in LANG_ROWS:
            LANG_ROWS[ml] = []
        LANG_ROWS[ml].append(row)

for lang in LANG_ROWS.keys():
    file_name = f'{lang}.csv'
    with open(file_name, 'w') as file:
        cw = csv.DictWriter(file, fieldnames=FIELD_NAMES)
        cw.writeheader()
        for row in LANG_ROWS[lang]:
            cw.writerow(row)
