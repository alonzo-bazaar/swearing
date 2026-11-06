#!/usr/bin/env perl

# count given swear words in given files
use strict;
use warnings;

use feature 'signatures';

use File::Find;
use File::Spec;
use Time::HiRes qw(time);

# get words
sub stripped_lines($fn) {
    open(my $lines_fh, "<", $fn) or die "could not open file $fn: $!";
    my @ls = map { $_ =~ s/^\s*|\s*$//g; $_ } <$lines_fh>;
    close($lines_fh) or die "could not close file handle to $fn: $!";

    return @ls;
}

sub slurp_fn($fn) {
    open(my $lines_fh, "<", $fn) or die "could not open file $fn: $!";
    my $slurped = join '', <$lines_fh>;
    close($lines_fh) or die "could not close file handle to $fn: $!";

    return $slurped;
}

my @WORDS = stripped_lines("fulldict.txt");

# idea 1:
# one ripgrep call every word

sub count_project($word, $glob, $dir) {
    my $total=0;

    open(my $ripgrep_out, '-|',
        'rg',
        '--no-ignore', '--count-matches', '--no-filename',
        '-i', "\\b$word\\b", '-g', $glob,
        $dir)
        or die "could not run ripgrep: $!";

    while(<$ripgrep_out>) { $total += $_; }
    return $total;
}

sub rg_idea() {
    foreach my $word (@WORDS) {
        print +(join ',', ($word, count($word, '*.[ch]', 'linux')))."\n" ;
    }
}

# idea 2:
# avoid having to read all files once per word by
# foreach file
# - slurp
# - match everything
# - move to next file
@WORDS = qw(fuck shit cunt);
my @WORDS_RE = map { [$_, qr/\b$_\b/i] } @WORDS;
my %COUNTS = (); foreach (@WORDS) { $COUNTS{$_} = 0; }

sub iter_files($dir, $file_regex, $proc) {
    find(sub {
            return if (not -f) or -d;
            if($_ =~ $file_regex) { $proc->($_); }
        }, $dir);
}

sub reap_files($dir, $file_regex) {
    my @files=();
    find(sub {
            return if (not -f) or -d;
            if($_ =~ $file_regex) { push @files, File::Spec->rel2abs($_); }
        }, $dir);
    return @files;
}

sub if_idea() {
    my @files = reap_files('linux', qr(\.[ch]$));

    foreach(@files) {
        print "$_\n";
        my $file_contents = slurp_fn($_);
        foreach my ($word, $re) (map {@{$_}} @WORDS_RE) {
            my $count = () = $file_contents =~ /$re/g;
            $COUNTS{$word}+=$count;
        }
    }
}

if_idea();
print join "\n", %COUNTS;
