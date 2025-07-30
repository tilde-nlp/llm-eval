#!/usr/bin/env bash
set -euo pipefail

# sanity check
echo "client.sh parallel status:"
which parallel || echo "❌ parallel not in PATH"

# --- args handed in from srun ---------------------------------------------
total=$1        # how many file names follow
shift           # drop $1

# slice the next $total positional parameters into an array
files=( "${@:1:total}" )
shift "$total"  # discard those we just stored

# whatever is left are the port numbers
PORTS=( "$@" )

echo "Client received ${#files[@]} files: ${files[*]}"
echo "Client received ${#PORTS[@]} ports: ${PORTS[*]}"

# Wait for the servers to be ready
wait_for_server () {
    until curl -s "http://0.0.0.0:$1/v1/models" >/dev/null; do
        echo "Waiting for server on port $1…"; sleep 10
    done
}
for p in "${PORTS[@]}"; do wait_for_server "$p"; done

echo "All servers are ready. Preparing data..."
# TODO: make this configurable based on num ports
# ── 3b. Split work into four ~equal chunks ────────────────────────────────────
base=$(( total / 4 )); extra=$(( total % 4 ))
offset=0
for idx in {1..4}; do
    size=$base; (( idx <= extra )) && (( size++ ))
    declare -n grp="grp$idx"
    grp=( "${files[@]:offset:size}" )
    offset=$(( offset + size ))

    # Log the group contents
    echo "Group $idx (port: ${PORTS[$((idx-1))]}):"
    for f in "${grp[@]}"; do
        echo "  $f"
    done
done
declare -a groups=(grp1 grp2 grp3 grp4)

# ── 3c. Kick off translators ─────────────────────────────────────────────────
export PYTHONNOUSERSITE=1

#### updated script
# Function to run translation on a single file
translate_file() {
    local file="$1"
    local port="$2"

    echo "Starting translation: $file on port $port"
    echo "PWD: $(pwd)"
    
    [[ -f "${file}.done" ]] && { echo "Skipping $file"; return 0; }

    if time {
        PYTHONUNBUFFERED=1 python3 bench_translator.py \
            --model "$MODEL_DIR" \
            --url "http://0.0.0.0:${port}" \
            --input_file "$file" \
            --format "json"
    }
    then
        touch "${file}.done"
        return 0
    else
        echo "❌ translator failed for $file" >&2
        return 1
    fi
}


export -f translate_file

### - NOT TRULY PARALLEL

# # Loop over port-specific groups and run with parallel
# for idx in "${!groups[@]}"; do
#     declare -n g="${groups[$idx]}"
#     port="${PORTS[$idx]}"
    
#     # Prepare input as: "file port"
#     printf "%s\t%s\n" "${g[@]/%/	$port}" | \
#         parallel --ungroup -j50 --colsep '\t' translate_file {1} {2} &
# done

# wait  # Wait for all backgrounded parallel jobs to finish

for i in "${!files[@]}"; do
    file="${files[$i]}"
    port="${PORTS[$((i % ${#PORTS[@]}))]}"
    echo -e "$file\t$port"
done | parallel --ungroup -j50 --colsep '\t' translate_file {1} {2}