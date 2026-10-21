use strict;
use warnings;

# debugging
sub println  ($thing) { print "$thing\n"; }
sub sprintln ($thing) { print "$thing\n"; }
sub aprintln (@thing) { print "@thing\n"; }


sub triml ($s) { $s =~ s/^\s*//g      ; return $s ; }
sub trimr ($s) { $s =~ s/\s*$//g      ; return $s ; }
