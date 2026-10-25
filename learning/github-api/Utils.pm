# module metadata
# ---------------
package Utils;
require Exporter;
our @ISA    = ('Exporter');
our @EXPORT = ('def',
               'sprintln', 'aprintln', 'println',
               'char_at', 'str_chars',
               'quote_if_space',
               'triml', 'trimr', 'trimlr', 'trim',
               'percent_encode_char', 'percent_encode_str',
               'slurp_fn', 'slurp',
               'take', 'drop',
    );
our @EXPORT_OK = @EXPORT;
our $VERSION = 1.00;

# module begins here
# ------------------
use strict;
use warnings;
use feature 'signatures';

# provide default value
# ---------------------
sub def($a, $b) {
    return (defined $a)?$a:$b;
}

# println&Co.
# -----------
sub sprintln ($thing) {
    print "$thing\n";
}
sub aprintln (@thing) {
    print "@thing\n";
}
sub println  ($thing) {
    return sprintln($thing);
}

# string wrangling utility functions
# ----------------------------------

# return "character" (length 1 string) of $s at index $i
sub char_at ($s, $i) {
    return substr($s, $i-1, 1);
}
# turns string into list of "characters" (length 1 strings)
sub str_chars ($s) {
    return map { char_at($s, $_) } 1..length($s);
}
# put quotes around a string if the string contains any whitespace
sub quote_if_space ($s) {
    return $s=~/\s/?"\"$s\"":$s;
}
# remove leading whitespace in a string
sub triml  ($s) {
    $s =~ s/^\s*//g ; return $s;
}
# remove trailing whitespace in a string
sub trimr  ($s) {
    $s =~ s/^\s*|\s*$//g ; return $s;
}
# remove leading and trailing whitespace in a string
sub trimlr  ($s) {
    $s =~ s/^\s*|\s*$//g ; return $s;
}
sub trim  ($s) {
    return trimlr($s);
}

# URI percent encoding
# --------------------
# note: this is encoding to be applied to data present in the URI
# it is not to be applied to the whole URI.
# The purpose of percent encoding is to escape keyword chars of a URI
# when they are present in a data field of said URI
# (for instance: having the string "hello/world" as a data filed
# without the "/" being interpreted as a syntax element of the URI
#
# from: https://www.rfc-editor.org/info/rfc3986/#section-2.3
# unreserved  = ALPHA / DIGIT / "-" / "." / "_" / "~"
sub percent_encode_char ($c) {
    return $c =~ /^[A-Za-z0-9\-\._~]$/ ? $c : sprintf("%%%X", ord($c));
}
sub percent_encode_str ($s) {
    return join('', map { percent_encode_char($_) } str_chars($s));
}

# file wrangling
# --------------
sub slurp_fn ($fn) { 
    open(SLURPED_FILE, "<", $fn) or die "cannot open file $fn for slurping: $!";
    my $fc = join '', <SLURPED_FILE>;
    close(SLURPED_FILE);
    return $fc;
}
sub slurp($fn) {
    return slurp_fn($fn);    
}

# take and drop as you'd see them in like, most functional programming languages
# they're just very nifty utility functions
sub take ($n, @arr) {
    if (abs($n) > @arr) {
        die "TAKE: invalid taken amount $n in array of length ".scalar(@arr)." (valid indices [0..$#arr])";
    }
    if ($n >= 0) {
        # take 0 should yield ()
        # take 1 should yield (arr[0])
        # and so on
        return (@arr)[0 .. ($n - 1)];
    }
    else {
        # take -1 should yield (arr[0], .. arr[$#arr-1])
        # take -2 should yield (arr[0], .. arr[$#arr-2])
        # and so on
        return (@arr)[0 .. $#arr + $n];
    }
}
sub drop ($n, @arr) {
    if (abs($n) > @arr) {
        die "DROP: invalid dropped amount $n in array of length ".scalar(@arr)."(valid indices [0..$#arr])";
    }
    if ($n >= 0) {
        return (@arr)[$n .. $#arr];
    }
    else {
        return (@arr)[($#arr + $n + 1) .. $#arr];
    }
}

# test code for when you wanna make tests for this
# my @a = (1, 2, 3);
# foreach (0..scalar(@a)+1) {
#     print "take $_: "; println( join ' - ', take($_, @a) );
#     print "drop $_: "; println( join ' - ', drop($_, @a) );
# }
# foreach (0..scalar(@a)+1) {
#     print "take -$_: "; println( join ' - ', take(-$_, @a) );
#     print "drop -$_: "; println( join ' - ', drop(-$_, @a) );
# }

# this is required for some reason
1;
