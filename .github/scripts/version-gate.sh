#!/usr/bin/env bash
# Prints "validate" when the Secant version is newer than 0.2.0, the last
# release without `bundle validate`, and "skip" when it is 0.2.0 or older.
# It reads the version only, never whether a command works, so a broken
# `validate` cannot hide behind it. A version it cannot read fails.
# The first Secant release after 0.2.0 deletes this gate.
set -euo pipefail

version=${1-}
number='(0|[1-9][0-9]*)'
if [[ ! $version =~ ^$number\.$number\.$number(-[0-9A-Za-z.-]+)?(\+[0-9A-Za-z.-]+)?$ ]]; then
  echo "Cannot read a Secant version from '$version'." >&2
  exit 1
fi
major=${BASH_REMATCH[1]}
minor=${BASH_REMATCH[2]}
patch=${BASH_REMATCH[3]}

# Numbers compare as numbers, so 0.10.0 is newer than 0.2.0. A pre-release of
# 0.2.0 is older than 0.2.0 itself.
if ((major > 0 || minor > 2 || (minor == 2 && patch > 0))); then
  echo validate
else
  echo skip
fi
