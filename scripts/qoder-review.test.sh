#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
runner="$script_dir/qoder-review.sh"

set +e
output=$("$runner" invalid-target 2>&1)
status=$?
set -e

[[ $status -eq 64 ]] || {
  printf 'expected exit 64 for invalid target, got %s\n' "$status" >&2
  exit 1
}

[[ $output == *"Usage:"* ]] || {
  printf 'expected usage text for invalid target\n' >&2
  exit 1
}

run_qoder_body=$(awk '/^run_qoder\(\)/,/^}/' "$runner")
prompt_argument="\"\$1\""
[[ $run_qoder_body != *"$prompt_argument"* ]] || {
  printf 'Qoder prompt must be streamed on stdin, not exposed in process arguments\n' >&2
  exit 1
}

printf 'qoder-review contracts: ok\n'
