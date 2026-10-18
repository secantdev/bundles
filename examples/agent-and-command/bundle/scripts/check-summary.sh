#!/usr/bin/env bash
# Passes when SUMMARY.md exists and holds 1 to 120 words.
set -euo pipefail

if [ ! -f SUMMARY.md ]; then
  echo "SUMMARY.md is missing."
  exit 1
fi

words=$(wc -w < SUMMARY.md | tr -d ' ')
echo "SUMMARY.md has $words words."
[ "$words" -ge 1 ] && [ "$words" -le 120 ]
