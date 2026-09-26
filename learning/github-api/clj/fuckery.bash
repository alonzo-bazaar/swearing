#!/usr/bin/env bash
GITHUB_TOKEN="$(cat "${HOME}/.methlab/github-tokens/alonzo")"
curl -L "https://api.github.com/search/code?q=FUCK"\
    -H "Accept: application/vnd.github+json"\
    -H "Authorization: Bearer ${GITHUB_TOKEN}"\
    -H "X-GitHub-Api-Version: 2022-11-28"
