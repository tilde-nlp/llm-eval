#!/usr/bin/env bash
set -euo pipefail

# sanity check
which parallel >/dev/null || { echo "parallel not in PATH"; exit 1; }

# --- args handed in from srun ---------------------------------------------
total=$1        # how many file names follow
shift           # drop $1

# slice the next $total positional parameters into an array
files=( "${@:1:total}" )
shift "$total"  # discard those we just stored

# whatever is left are the port numbers
PORTS=( "$@" )

bash ./client.sh "$total" "${files[@]}" "${PORTS[@]}"
