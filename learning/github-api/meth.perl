#!/usr/bin/env perl
use strict;
use warnings;

use feature 'signatures';

use Env qw(HOME);
use HTTP::Tiny;
use JSON::PP;

sub trim  ($s) { $s =~ s/^\s*|\s*$//g ; return $s ; }
# file wrangling
sub slurp ($fn) { 
    open(SLURPED_FILE, "<", $fn) or die "cannot open file $fn: $!";
    my $fc = <SLURPED_FILE>;
    close(SLURPED_FILE);
    return $fc;
}
sub quote_if_space ($s) { return $s=~/\s/?"\"$s\"":$s }

## parameters
# parameters for github api request
my $GITHUB_API_VERSION = '2026-03-10';
my $GITHUB_TOKEN = trim(slurp("$HOME/.methlab/github-tokens/alonzo"));
# top languages from
# https://innovationgraph.github.com/global-metrics/programming-languages 
# as of 19 Oct 2026
my @LANGUAGES_OF_INTEREST = ('javascript', 'python', 'typescript',
                             # 'shell', 'dockerfile',
                             'java', 'c++', 'c',
                             # 'makefile', 'batchfile',
                             'php', 'c#',
                             # 'powershell', 'cmake',
                             'kotlin', 'ruby', 'swift', 'go');
my $LANGUAGES_QUERY = join('+',
                           map { my $l = quote_if_space($_); "language:$l" }
                           @LANGUAGES_OF_INTEREST);;
my $PER_PAGE = 1;

# data collection side (our/client side) parameters
my $INPUT_SWEAR_FILE =  './wordlist.txt';
my $OUTPUT_COUNT_FILE = './counts.csv';

## script logic
# string wrangling
sub char_at ($s, $i) { return substr($s, $i-1, 1); }
sub str_chars   ($s) { return map { char_at($s, $_) } 1..length($s); }
# url percent encoding
# https://www.rfc-editor.org/info/rfc3986/#section-2.3
# unreserved  = ALPHA / DIGIT / "-" / "." / "_" / "~"
sub url_encode_char ($c) {
    return $c =~ /^[A-Za-z0-9\-\._~]$/ ? $c : sprintf("%%%X", ord($c));
}
sub url_encode_str ($s) {
    return join('', map {url_encode_char($_)} str_chars($s));
}


# send request
sub code_count_request(@words) {
    my $words_query = url_encode_str(join(' ',
                                          map { quote_if_space($_) } @words));
    my $req_url = join('', ("https://api.github.com/search/code",
                            "?q=$words_query",
                            "+in:file",
                            "+$LANGUAGES_QUERY",
                            "&per_page=$PER_PAGE"));

    open(REQ_OUT, '-|', 'curl',
    #print(join "\n",
         '--no-progress-meter', # porcoddio
         '-L', $req_url,
         '-H', "Accept: application/vnd.github.text-match+json",
         '-H', "Authorization: Bearer $GITHUB_TOKEN",
         '-H', "X-GitHub-Api-Version: $GITHUB_API_VERSION",
        );

    while(<REQ_OUT>) { print "$_"; } close(REQ_OUT);
}

code_count_request("Fuck ", "Fuck_", " Fuck", "_Fuck");
#code_count_request("fuck ", "fuck_", " fuck", "_fuck");
