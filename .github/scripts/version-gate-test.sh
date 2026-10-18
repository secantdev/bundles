#!/usr/bin/env bash
# Proves the version gate's comparison before the workflow relies on it.
set -euo pipefail

gate="$(dirname "$0")/version-gate.sh"
failures=0

expect() {
  local version=$1 want=$2 got
  if got=$(bash "$gate" "$version" 2>/dev/null); then :; else got=error; fi
  if [[ $got == "$want" ]]; then
    echo "ok   $version -> $got"
  else
    echo "FAIL $version -> $got, want $want"
    failures=$((failures + 1))
  fi
}

expect 0.1.0 skip
expect 0.1.9 skip
expect 0.2.0 skip
expect 0.2.0-rc.1 skip
expect 0.2.1 validate
expect 0.3.0 validate
expect 0.10.0 validate
expect 1.0.0 validate
expect 1.0.0-rc.1 validate
expect v0.3.0 error
expect 0.3 error
expect 00.3.0 error
expect "" error
expect "error: unknown option" error

((failures == 0))
