#!/usr/bin/env bash

set -euo pipefail

## parameters
# parameters for query to send to github
GITHUB_API_VERSION='2026-03-10'
GITHUB_TOKEN="$(cat "${HOME}/.methlab/github-tokens/alonzo")"
PER_PAGE='100'
LANGUAGES=( 'c++' )
LANGUAGES_QUERY_STRING= # initialized empty, populated when we have the functions to do it
# parameters for data collection on our side
INPUT_SWEAR_FILE='./wordlist.txt'
OUTPUT_COUNT_FILE='./counts.csv'

## utils
# shit yourself and die
fatal() {
    echo "[FATAL ERROR] $*" >&2
    exit 1
}

# not the safest approach out there but hey, bash be bash
# we only handle ' ', '-', '+', and '_' for now
url_encode() {
    local datum=$1
    datum="${datum// /%20}"
    datum="${datum//#/%23}"
    datum="${datum//+/%2B}"
    datum="${datum//-/%2D}"
    datum="${datum//_/%5F}"
    echo "$datum"
}
# like url_encode but wraps datum in double quotes (url percent encoded as %22)
url_quote() {
    echo "%22${ url_encode "$1" ; }%22"
}
# to put it in haskell-ese
# intercalate "+" $ map ("language:"++) $ map url_quote $@
# github api needs this to express multiple languages to search through
format_lang_array() {
    local acc=""
    local l
    for l in "$@"; do
        acc+="+language:${ url_quote "$l" ; }"
    done
    echo "${acc:1}"
}

LANGUAGES_QUERY_STRING="${ format_lang_array "${LANGUAGES[@]}" ; }"

# do the call to the github code search api
gh_code_search() {
    local searched_words_query=""
    local searched_word
    for searched_word in "$@"; do
        searched_words_query+="%20${ url_quote "${searched_word}" ; }"
    done
    searched_words_query="${searched_words_query:3}"

    curl --no-progress-meter\
        -L "https://api.github.com/search/code?q=${searched_words_query}+in:file+${LANGUAGES_QUERY_STRING}&per_page=${PER_PAGE}"\
        -H "Accept: application/vnd.github.text-match+json"\
        -H "Authorization: Bearer ${GITHUB_TOKEN}"\
        -H "X-GitHub-Api-Version: ${GITHUB_API_VERSION}"
}

# output number of occurences on github for needle $1 in langauges $LANGUAGES
count_instances() {
    gh_code_search "$@" | jq '.total_count'
}

gh_code_search "Fuck " " Fuck" "Fuck_" "_Fuck"

ignore_this() {
    # I will use this later
    echo "word,count" > "${OUTPUT_COUNT_FILE}"
    while read -r line; do
        occurences='null'
        # retry della query se me viene nullo
        while [[ "${occurences}" = 'null' ]]; do
            echo "counting ${line}..."
            occurences=${ count_occurences "${line}"; }
            sleep 6
        done
        printf '%s,%s\n' "${line}" "${occurences}" >> "${OUTPUT_COUNT_FILE}"
    done <"${INPUT_SWEAR_FILE}"
}
