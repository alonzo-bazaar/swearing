#!/usr/bin/env perl
use strict;
use warnings;

use feature 'signatures';

sub strip($s) { $s =~ s/^\s*|\s*$//g; return $s }
sub stripped_lines($fn) {
    open(my $lines_fh, "<", $fn) or die "could not open file $fn: $!";
    my @ls = map { strip $_ } <$lines_fh>;
    close($lines_fh) or die "could not close file handle to $fn: $!";

    return @ls;
}
sub cmd(@cmd) {
    open(FH, '-|', @cmd);
    my $out = strip(join '', <FH>);
    close FH;
    return $out;
}

# this is somehow *slower* than running rg (and having it read the file)
# once for every word in the wordlist
# lolwut
my $big_re = join '|', map { "\\b$_\\bs" } stripped_lines('wordlist');
system('rg', '-i', $big_re, '--count-matches', 'data/kjv.txt');
exit;
