# Runs the project's tests; the exit status becomes the tests-pass verdict.
# Change `npm test` to your project's own test command.
$ErrorActionPreference = 'Stop'

npm test
exit $LASTEXITCODE
