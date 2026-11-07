#!/usr/bin/env bash
count() {
    rg -i "\\b$1\\b" --count-matches data/kjv.txt
}

total=0
while read -r word; do
    i=${ count "$word" ; }
    total=$(( total +  i ))
done <wordlist

echo "$total"
