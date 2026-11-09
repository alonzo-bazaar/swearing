#!/usr/bin/env perl
use strict;
use warnings;

use feature 'signatures';

my $WORDLIST     = $ARGV[0];
my $SEARCHED_DIR = $ARGV[1];
my $GLOB         = $ARGV[2];

sub strip($s) { $s =~ s/^\s*|\s*$//g; return $s }
sub stripped_lines($fn) {
    open(my $lines_fh, "<", $fn) or die "could not open file $fn: $!";
    my @ls = map { strip $_ } <$lines_fh>;
    close($lines_fh) or die "could not close file handle to $fn: $!";

    return @ls;
}
sub strip_slurp_cmd(@cmd) {
    open(FH, '-|', @cmd);
    my $out = strip(join '', <FH>);
    close FH;
    return $out;
}

my @words=stripped_lines($WORDLIST);

sub sum(@arr) { my $acc = 0; foreach(@arr) { $acc+=$_; } return $acc; }

foreach my $word (@words) {
    my @rg_args = (
        ('-i', "\\b$word\\b"),
        $GLOB ? ('-g', $GLOB) : (),
        ('--count-matches', '--no-filename'),
        );
    my $count = strip_slurp_cmd('rg', @rg_args, $SEARCHED_DIR);
    
    $count = 0                         if not $count;
    $count = sum(split(/\s+/, $count)) if $count =~ /\s/;

    print "$word: $count\n";
}
