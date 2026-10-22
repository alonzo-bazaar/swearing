#!/usr/bin/env bash
# scratchpad (methlab) script
# STRICT=1; TRACE=1;

[[ -v STRICT ]] && set -euo pipefail
[[ -v TRACE  ]] && set -x

get_gh_token() {
    # put the code here to fetch your github token if GITHUB_TOKEN
    # isn't already exported as an environment variable
    cat "${HOME}/.methlab/github-tokens/alonzo"
}

GITHUB_API_VERSION='2026-03-10 '
[[ -v GITHUB_TOKEN ]] || GITHUB_TOKEN="${ get_gh_token ; }"
PER_PAGE='1'
# LANGUAGES=( 'c++' )

fatal() {
    echo "[FATAL ERROR] $*" >&2
    exit 1
}

# percent encode string
pes() {
    local datum="$1"
    # handle percent signs first so no future step encodes them
    datum="${datum//%/%25}"
    # handle everything else
    datum="${datum// /%20}"
    datum="${datum//\"/%22}"
    datum="${datum//#/%23}"
    datum="${datum//+/%2B}"
    datum="${datum//-/%2D}"
    datum="${datum//:/%3A}"
    datum="${datum//_/%5F}"
    echo "$datum"
}

join_with() {
    local sep="$1"
    local sep_len="${#sep}"
    shift

    if [[ "$#" = '0' ]]; then
        echo ""
        return
    fi

    local acc=""
    local i
    for i in "$@"; do
        acc+="${sep}${i}"
    done
    acc="${acc:sep_len}"
    echo "${acc}"
}

join () {
    join_with "" "$@"
}

idfk() {
    WS="${ pes "$1" ; }"
    echo -n "count of [$1]: "
    curl --no-progress-meter\
        -L "${ join "https://api.github.com/search/code"\
        "?q=${WS}"\
        "+in:file"\
        "+language:${ pes '"c"' ; }+language:${ pes '"go"' ; }"\
        "&per_page=${PER_PAGE}" ; }"\
        -H "Accept:  application/vnd.github.text-match+json"\
        -H "Authorization: Bearer ${GITHUB_TOKEN}"\
        -H "X-GitHub-Api-Version: ${GITHUB_API_VERSION}" | jq '.total_count'
    [[ $? ]] || fatal "query failed"
}
TRIES=( '"fuck"'
        '"shit"'
        '"fuck" "shit"'
        '"fuck" AND "shit"'
        '"fuck" "and" "shit"' )

for i in "${TRIES[@]}" ; do
    idfk "$i"
done

exit
