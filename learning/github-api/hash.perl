#!/usr/bin/env perl
use strict;
use warnings;
use feature 'signatures';

# allowed keys are words, langs, and that's it I guess
sub getopts($opts_ref, $kv_pairs_ref) {
    my %opts = %{$opts_ref};
    my @kv_pairs = @{$kv_pairs_ref};
    my @kv_pairs_ks = map { $_->[0] } @kv_pairs;

    my @res = ();

    foreach (@kv_pairs) {
        my ($k, $v) = ($_->[0], $_->[1]);
        if (grep { $_ eq $k } keys(%opts)) {
            push @res, $opts{$k};
        }
        else {
            push @res, $v->();
        }
    }
    return @res;
}

sub required($k) {
    return [$k, sub { die "parameter $k is required!" } ];
}

sub optional($k, $def) {
    return [$k, sub { return $def ; } ];
}

