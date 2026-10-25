#!/usr/bin/env perl
use strict;
use warnings;
use feature 'signatures';

# initial setup and import packages
# ---------------------------------
# first of all make perl look for modules in script directory as well
# code from: https://stackoverflow.com/questions/4703682
# Does Perl look in the current directory (.) for modules?
# and
# https://perldoc.perl.org/5.26.0/perldelta#Removal-of-the-current-directory-(%22.%22)-from-@INC
# this code also chdir's in the directory containing the script
# this is just good practice
BEGIN {
    use Cwd 'abs_path';
    use File::Basename;
    my $SCRIPT_DIR = dirname(abs_path($0));
    chdir $SCRIPT_DIR or die "could not chdir into $SCRIPT_DIR: $!";
    push @INC, '.';
}

use Env qw(HOME);
use JSON::PP;
use Utils; # in ./Utils.pm, reason for BEGIN block above

# script parameters
# -----------------
## github api request parameters
## -----------------------------
my $GITHUB_TOKEN = trim(slurp("$HOME/.methlab/github-tokens/alonzo"));
my $GITHUB_API_VERSION = '2026-03-10';
my $PER_PAGE = 1;
# top languages from
# https://innovationgraph.github.com/global-metrics/programming-languages 
# as of 19 Oct 2026
my @ALL_LANGS = ('javascript', 'python', 'typescript',
                 # 'shell', 'dockerfile',
                 'java', 'c++', 'c',
                 # 'makefile', 'batchfile',
                 'php', 'c#',
                 # 'powershell', 'cmake',
                 'kotlin', 'ruby', 'swift', 'go');
my @ALL_SWEARS = ('motherfucker', 'asshole',
                  'cunt', 'fuck', 'shit', 'bitch', 'dick',
                  'damn', 'darn', 'gosh',);

# script core logic
# -----------------

## send requests
## -------------

# https://docs.github.com/en/rest/search/search?apiVersion=2026-03-10#search-code
sub code_count_response(%kwargs) {
    my @words = @{$kwargs{'words'}} or die 'words required';
    my @langs = @{$kwargs{'langs'}} or die 'langs required';

    # note: when providing multiple words the github api takes this as an *and*
    # code_count_response(words=>['a', 'b', 'c']) will search for files
    # containing a AND b AND c
    my $words_query = percent_encode_str(join(' ', map { "\"$_\"" } @words));
    my $langs_query = join('+', map { percent_encode_str("language:\"$_\"") }
                           @langs);
    my $req_url = join('', ("https://api.github.com/search/code",
                            "?q=", $words_query,
                            "+",   $langs_query,
                            "+",   percent_encode_str("in:file"),
                            "&per_page=", $PER_PAGE,
                       ));
    open(RES_OUT, '-|', 'curl',
    #print(join "\n", # print debugging in case (must comment line above for it)
         '--no-progress-meter',
         '-L', $req_url,
         '-H', "Accept: application/vnd.github.text-match+json",
         '-H', "Authorization: Bearer $GITHUB_TOKEN",
         '-H', "X-GitHub-Api-Version: $GITHUB_API_VERSION",
        );
    # (when print debugging uncomment these as well)
    #while(<RES_OUT>){ print ; }    
    #exit;

    # NOTE: do join '', <> to slurp a stream in a string instead of <>
    # in a scalar context <> gives only one line
    # which works if curl gives us a json without newlines
    # but that's not always the case
    # in a vector contexs (which will be supplied by join) <> does slurp
    # all lines, and to join them you can join '', <>
    # (fuck my life)
    my $response_contents = join '', <RES_OUT>;
    close(RES_OUT);
    $response_contents = decode_json($response_contents);
    return %{$response_contents};
}


# https://docs.github.com/en/rest/search/search?apiVersion=2026-03-10#search-repositories
sub repo_count_response(%kwargs) {
    my @words     = @{$kwargs{'words'}}    or die 'words required';
    my @langs     = @{$kwargs{'langs'}}    or die 'langs required';
    my $min_stars =   $kwargs{'min_stars'} or die 'min_stars required';

    my $words_query = percent_encode_str(join(' ', map { "\"$_\"" } @words));
    my $langs_query = join('+', map { percent_encode_str("language:\"$_\"") }
                           @langs);
    my $req_url = join('', ("https://api.github.com/search/repositories",
                            "?q=", $words_query,
                            "+",   $langs_query,
                            "+",   percent_encode_str("stars:>=$min_stars"),
                            "&per_page=", $PER_PAGE,
                       ));
    open(RES_OUT, '-|', 'curl',
         '--no-progress-meter',
         '-L', $req_url,
         '-H', "Accept: application/vnd.github.text-match+json",
         '-H', "Authorization: Bearer $GITHUB_TOKEN",
         '-H', "X-GitHub-Api-Version: $GITHUB_API_VERSION",
        );

    my $response_contents = join '', <RES_OUT>;
    close(RES_OUT);
    $response_contents = decode_json($response_contents);
    return %{$response_contents};
}

sub code_count(%kwargs) {
    my %response_json_object = code_count_response(%kwargs);
    return $response_json_object{'total_count'};
}
sub repo_count(%kwargs) {
    my %response_json_object = repo_count_response(%kwargs);
    return $response_json_object{'total_count'};
}

# outputs all info for demo in a csv format
# (to be table'd later)
sub demo () {
    my ($lang, $swear, $min_stars);

    print "search type,programming language,min stars,swear word,number of matches\n";
    # which swear words are more common in code?
    foreach $swear (@ALL_SWEARS) {
        print("code,all langs,-1,$swear,"
              .code_count(words=>[$swear],
                          langs=>\@ALL_LANGS)
              ."\n");
        sleep 6;
    }

    # swear frequency in code by swear word and (code) language
    foreach $lang (@ALL_LANGS) {
        foreach $swear (@ALL_SWEARS) {
            print("code,$lang,-1,$swear,"
                  .code_count(words=>[$swear],
                              langs=>[$lang])
                  ."\n");
            sleep 6;
        }
    }

    # which swear words are more common in repo metadata?
    # (title, readme, and the like)
    # with varying constraints on stars
    for $min_stars ((0, 5, 10)) {
        foreach $swear (@ALL_SWEARS) {
            print("repo,all langs,$min_stars,$swear,"
                  .repo_count(words=>[$swear],
                              langs=>\@ALL_LANGS,
                              min_stars=>$min_stars)
                  ."\n");
            sleep 6;
        }
    }

    # which swear words are more common in repo metadata, by programming language
    # with varying constraints on stars

    for $min_stars ((0, 5, 10)) {
        foreach $lang (@ALL_LANGS) {
            foreach $swear (@ALL_SWEARS) {
                print("repo,$lang,$min_stars,$swear,"
                      .repo_count(words=>[$swear],
                                  langs=>[$lang],
                                  min_stars=>$min_stars)
                      ."\n");
                sleep 6;
            }
        }
    }
}

demo();
