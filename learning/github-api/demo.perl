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
my @LANGS =
    ('javascript', 'python', 'typescript',
     # 'shell', 'dockerfile',
     'java', 'c++', 'c',
     # 'makefile', 'batchfile',
     'php', 'c#',
     # 'powershell', 'cmake',
     'kotlin', 'ruby', 'swift', 'go');
my $MIN_STARS = 5;

my @SWEARS =
    ('motherfucker', 'asshole',
     'cunt', 'fuck', 'shit', 'bitch', 'dick',
     'damn', 'darn', 'gosh',);

# script core logic
# -----------------
## send request
## ------------
# https://docs.github.com/en/rest/search/search?apiVersion=2026-03-10#search-repositories
sub code_count_response(%kwargs) {
    my @words = @{$kwargs{'words'}} or die 'words required';
    my @langs = @{def($kwargs{'langs'}, \@LANGS)};
    my $min_stars = def($kwargs{'min_stars'} , $MIN_STARS);

    # note: when providing multiple words the github api takes this as an *and*
    # code_count_response(words=>['a', 'b', 'c']) will search for files
    # containing a AND b AND c
    my $words_query = percent_encode_str(join(' ', map { "\"$_\"" } @words));
    my $langs_query = join('+', map { percent_encode_str("language:\"$_\"") }
                           @langs);
    my $req_url = join('', ("https://api.github.com/search/code",
                            "?q=", $words_query,
                            "+",   percent_encode_str("in:file"),
                            "+",   $langs_query,
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
    # all lines
    # (fuck my life)
    my $response_contents = join '', <RES_OUT>;
    close(RES_OUT);
    $response_contents = decode_json($response_contents);
    return %{$response_contents};
}

sub repo_count_response(%kwargs) {
    my @words = @{$kwargs{'words'}} or die 'words required';
    my $min_stars = def($kwargs{'min_stars'} , $MIN_STARS);

    my $words_query = percent_encode_str(join(' ', map { "\"$_\"" } @words));
    my $req_url = join('', ("https://api.github.com/search/repositories",
                            "?q=", $words_query,
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
    my ($lang, $swear);

    print "mode,constraint,swear,amount\n";
    # swear frequency by swear
    foreach $swear (@SWEARS) {
        print "code,all_langs,$swear,".code_count(words=>[$swear], langs=>\@LANGS)."\n";
        sleep 6;
    }

    # swear frequency by swear and lang
    foreach $lang (@LANGS) {
        foreach $swear (@SWEARS) {
            print "code,$lang,$swear,".code_count(words=>[$swear], langs=>[$lang])."\n";
            sleep 6;
        }
    }

    # frequency of swear word usage in repository metadata
    # (title, readme, and the like)
    # ----------------------------------------------------
    foreach $swear (@SWEARS) {
        print "repo,0,$swear,".repo(words=>[$swear], min_stars=>0)."\n";
        sleep 6;
    }

    # frequency of swear word usage in repository metadata
    # for repositorories with at least 5 stars
    # ----------------------------------------------------
    foreach $swear (@SWEARS) {
        print "repo,5,$swear,".repo(words=>[$swear], min_stars=>5)."\n";
        sleep 6;
    }

    # frequency of swear word usage in repository metadata
    # for repositorories with at least 10 stars
    # ----------------------------------------------------
    foreach $swear (@SWEARS) {
        print "repo,10,$swear,".repo(words=>[$swear], min_stars=>10)."\n";
        sleep 6;
    }
}

demo();
