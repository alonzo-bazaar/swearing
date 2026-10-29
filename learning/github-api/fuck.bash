#!/usr/bin/env bash

REPO='apache/httpd'
URL="https://github.com/${REPO}"
METH_DIR="${PWD}/meth"
WORDS=( fuck shit cunt bitch dick )

echo "${SECONDS}, cloning..."
git clone -q --depth 1 "${URL}" "$METH_DIR"

echo "${SECONDS},word,count"
for word in "${WORDS[@]}"; do
    echo -n "${SECONDS},${word},"
    grep "\\b${word}\\b" -ri "${METH_DIR}" | wc -l
done

rm -rf "${METH_DIR}"
