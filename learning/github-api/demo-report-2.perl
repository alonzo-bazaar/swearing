#!/usr/bin/env perl
# for any undocumented bullshit here see demo-report-1.perl
# the common code between these two demos is discussed there

# head
# ----
use strict;
use warnings;
use feature 'signatures';

BEGIN {
    use Cwd 'abs_path';
    use File::Basename;
    my $SCRIPT_DIR = dirname(abs_path($0));
    chdir $SCRIPT_DIR or die "could not chdir into $SCRIPT_DIR: $!";
    push @INC, '.';
}

# deps
# ----
use Env qw(HOME);
use JSON::PP;
use Utils;


# params
# ------
my $GITHUB_TOKEN = trim(slurp("$HOME/.methlab/github-tokens/alonzo"));
my $GITHUB_API_VERSION = '2026-03-10';
my $PER_PAGE = 1;

my @ALL_LANGS = ('javascript', 'python', 'typescript', 'java', 'c++', 'c',
                 'php', 'c#', 'kotlin', 'ruby', 'swift', 'go');
my @ALL_SWEARS = ('motherfucker', 'asshole',
                  'cunt', 'fuck', 'shit', 'bitch', 'dick',
                  'damn', 'darn', 'gosh',);
sub code_count_response(%kwargs) {
    # get args from kwargs
    my @words     = @{$kwargs{'words'}};
    my @langs     = @{$kwargs{'langs'}};
    my $repo      =   $kwargs{'repo'};
    my $per_page  =   $kwargs{'per_page'};
    if (not grep $_ eq 'words'    , keys(%kwargs)) { die 'words required!' }
    if (not grep $_ eq 'langs'    , keys(%kwargs)) { @langs = (); }
    if (not grep $_ eq 'repo'     , keys(%kwargs)) { $repo  = ""; }
    if (not grep $_ eq 'per_page' , keys(%kwargs)) { $per_page  = $PER_PAGE; }

    # construct elements of the query
    my $words_query = percent_encode_str(join(' ', map { "\"$_\"" } @words));
    my $langs_query = join('+', map { percent_encode_str("language:\"$_\"") }
                           @langs);
    my $repo_query = percent_encode_str("repo:$repo");
    my $other_opts = join('+',
                          map { percent_encode_str($_) }
                          ( "in:file", )); # other options to be added

    my $req_url = join('', ("https://api.github.com/search/code",
                            "?q=$words_query",
                            (@langs?"+$langs_query":""),
                            ($repo? "+$repo_query" :""),
                            "+$other_opts",
                            "&per_page=$per_page",
                       ));

    # send the request and get a file handle from which to read the response
    open(RES_OUT, '-|', 'curl',
         '--no-progress-meter',
         '-L', $req_url,
         '-H', "Accept: application/vnd.github.text-match+json",
         '-H', "Authorization: Bearer $GITHUB_TOKEN",
         '-H', "X-GitHub-Api-Version: $GITHUB_API_VERSION",
        );
    while(<RES_OUT>){ print ; }
    exit;

    my $response_contents = join '', <RES_OUT>;
    close(RES_OUT);
    $response_contents = decode_json($response_contents);
    return %{$response_contents};
}

code_count_response(words=>['shit'],
                    langs=>[],
                    repo=>'torvalds/linux',
                    per_page=>10);
