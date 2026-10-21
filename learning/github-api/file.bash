#!/usr/bin/env bash

[[ -n "${STRICT}" ]] && set -euo pipefail
[[ -n "${TRACE}"  ]] && set -x

## parameters

# parameters for query to send to github
GITHUB_API_VERSION='2026-03-10'
GITHUB_TOKEN="$(cat "${HOME}/.methlab/github-tokens/alonzo")"
PER_PAGE='100'
LANGUAGES=( 'c++' )
# language query string, initialized empty
# will be populated once we have the function to create it
LANGUAGES_QUERY_STRING=

# parameters for data collection on our side
INPUT_SWEAR_FILE='./wordlist.txt'
OUTPUT_COUNT_FILE='./counts.csv'

## utils

# shit yourself and die
fatal() {
    echo "[FATAL ERROR] $*" >&2
    exit 1
}

# do url percent encoding on $1
# not the safest approach out there but hey, bash be bash
# we only handle ' ', '-', '+', '#', and '_' for now
url_encode() {
    local datum="$1"
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
# to put it in python
# '%2B'.join([f'language:"{lang}"'] for lang in args)
# ('%2B' is url_encode '+')
# this is the format the github api expects if we want to say
# we have multiple languages to search through
format_lang_array() {
    local acc=""
    local l
    for l in "$@"; do
        acc+="+language:${ url_quote "$l" ; }"
    done
    acc="${acc:1}"
    acc="${acc//+/%2B}"
    echo "${acc}"
}

LANGUAGES_QUERY_STRING="${ format_lang_array "${LANGUAGES[@]}" ; }"

# do the call to the github code search api
gh_code_search() {
    local searched_words_query=""
    local searched_word
    for searched_word in "$@"; do
        searched_words_query+=" ${ url_quote "${searched_word}" ; }"
    done
    searched_words_query="${searched_words_query:1}"
    searched_words_query="${searched_words_query// /%2O}"

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
    # I will use this code later
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
