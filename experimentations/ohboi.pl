#!/usr/bin/env perl
use strict;
use warnings;

use feature 'signatures';

sub strip($s) { $s =~ s/^\s*|\s*$//g; return $s }
sub cmd(@cmd) {
    open(FH, '-|', @cmd);
    my $out = strip(join '', <FH>);
    close FH;
    return $out;
}

my $total = 0;
while(<>) {
    my $word = strip($_);
    my $count = cmd('rg',
                    '-i', "\\b$word\\b",
                    '--count-matches',
                    'data/kjv.txt');
    $count or $count = 0;
    print "$word: $count\n";
    #$total+=$count;
}
#print "$total\n";
