#!/usr/bin/env perl
use strict;
use warnings;
use feature 'signatures';

# import packages and initial setup
# ---------------------------------
# first of all make perl look for modules in script directory as well
# code from: https://stackoverflow.com/questions/4703682
# Does Perl look in the current directory (.) for modules?
# and
# https://perldoc.perl.org/5.26.0/perldelta#Removal-of-the-current-directory-(%22.%22)-from-@INC
BEGIN {
    use Cwd 'abs_path';
    use File::Basename;
    my $SCRIPT_DIR = dirname(abs_path($0));
    chdir $SCRIPT_DIR or die "could not chdir into $SCRIPT_DIR: $!";
    push @INC, $SCRIPT_DIR;
}
use Env qw(HOME);
use JSON::PP;
use Utils; # in ./Utils.pm, reason for BEGIN block above

# script parameters
# -----------------
## data collection parameters
## --------------------------
my $INPUT_SWEAR_FILE =  './wordlist.txt';
my $OUTPUT_COUNT_FILE = './counts.csv';
## github api request parameters
## -----------------------------
my $PER_PAGE = 1;
my $GITHUB_TOKEN = trim(slurp("$HOME/.methlab/github-tokens/alonzo"));
my $GITHUB_API_VERSION = '2026-03-10';
# top languages from
# https://innovationgraph.github.com/global-metrics/programming-languages 
# as of 19 Oct 2026
my @LANGUAGES_OF_INTEREST =
    ('javascript', 'python', 'typescript',
      # 'shell', 'dockerfile',
      'java', 'c++', 'c',
      # 'makefile', 'batchfile',
      'php', 'c#',
      # 'powershell', 'cmake',
      'kotlin', 'ruby', 'swift', 'go');
my $LANGUAGES_QUERY =
    join('+', map { percent_encode_str("language:".quote_if_space($_)) }
              @LANGUAGES_OF_INTEREST);

# script core logic
# -----------------

## send request
## ------------
sub code_count_response(@words) {
    my $words_query = percent_encode_str(join(' ', map { "\"$_\"" } @words));
    print $words_query."\n";
    my $req_url = join('', ("https://api.github.com/search/code",
                            "?q=", "$words_query",
                            " ",   percent_encode_str("in:file"),
                            " ",   "$LANGUAGES_QUERY",

                            "&per_page=$PER_PAGE"));
    open(RES_OUT, '-|', 'curl',
    #print(join "\n",
         '--no-progress-meter', # porcoddio
         '-L', $req_url,
         '-H', "Accept: application/vnd.github.text-match+json",
         '-H', "Authorization: Bearer $GITHUB_TOKEN",
         '-H', "X-GitHub-Api-Version: $GITHUB_API_VERSION",
        );

    my $response_contents = <RES_OUT>;
    close(RES_OUT);
    $response_contents = decode_json($response_contents);
    return %{$response_contents};
}

sub code_count(@words) {
    my %j = code_count_response(@words);
    my $c = $j{'total_count'};
    return $c;
}

# github search rest api is case insensitive
# this might become a problem later on
# println(code_count("fuck"));
println(code_count("fuck "));
println(code_count(" fuck"));
println(code_count(" fuck", "fuck "));
