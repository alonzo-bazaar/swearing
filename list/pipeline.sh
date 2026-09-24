#!/usr/bin/env sh
perl -ne 'chomp;print"$1\n" if $_ =~ qr!^\s*<title>([a-zA-z- ]+)</title>\s*!;'\
         fulldict.xml > fulldict.txt
./merge.bqn fulldict.txt en.txt wikipedia-list.txt > merged.txt
./split.bqn merged.txt plurals.txt > singulars.txt
./camel.bqn singulars.txt > final.txt
