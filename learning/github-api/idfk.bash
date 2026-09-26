#!/usr/bin/env bash

# I don't have the best token management system out there, lol
GITHUB_TOKEN="$(cat "${HOME}/.methlab/github-tokens/alonzo")"
INPUT_SWEAR_FILE='./wordlist.txt'
OUTPUT_COUNT_FILE='./counts.csv'

count_occurences() {
    local needle="$1"
    curl --no-progress-meter\
        -L "https://api.github.com/search/code?per_page=1&q=${needle}"\
        -H "Accept: application/vnd.github+json"\
        -H "Authorization: Bearer ${GITHUB_TOKEN}"\
        -H "X-GitHub-Api-Version: 2026-03-10"\
        | jq '.total_count'
}

count_occurences "kitemmuort"
exit

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

