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
PORT_COUNT=${#PORTS[@]}

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

# ── 3c. Kick off translators ─────────────────────────────────────────────────
export PYTHONNOUSERSITE=1

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
            --format "json" \
            --few_shot_file "$FEW_SHOT_FILE" \
            --n_few_shot "$N_FEW_SHOT" \
            --model_type "$MODEL_TYPE"
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

# Distribute files evenly across ports and process in parallel
declare -a assignments
for i in "${!files[@]}"; do
    file="${files[$i]}"
    port="${PORTS[$((i % PORT_COUNT))]}"
    assignments+=("$file $port")
done

declare -A has_job
for entry in "${assignments[@]}"; do
  port="${entry##* }"
  has_job[$port]=1
done

# rebuild PORTS/PORT_COUNT to only the ones we actually used
old_ports=( "${PORTS[@]}" )
PORTS=()
for p in "${old_ports[@]}"; do
    # use “:-” so that unset has_job[$p] becomes “” rather than an error
    if [[ -n "${has_job[$p]:-}" ]]; then
        PORTS+=( "$p" )
    fi
done
PORT_COUNT=${#PORTS[@]}

# Group assignments by port
declare -A grouped
for entry in "${assignments[@]}"; do
    port="${entry##* }"
    grouped[$port]+="$entry"$'\n'
done

# Debug: show grouped jobs
echo -e "\nJobs per port (before interleaving):"
for port in "${PORTS[@]}"; do
    echo "Port $port:"
    echo -n "${grouped[$port]}" | sed 's/^/  - /'
done

# Build port-specific arrays and determine the maximum group size
max_len=0
for port in "${PORTS[@]}"; do
    array_name="jobs_$port"
    mapfile -t "$array_name" <<< "${grouped[$port]}"
    eval "len=\${#${array_name}[@]}"
    (( len > max_len )) && max_len=$len
done

# Interleave jobs across ports
interleaved=()
for ((i = 0; i < max_len; i++)); do
    for port in "${PORTS[@]}"; do
        array_name="jobs_$port"
        # ← changed here to default-empty expansion
        eval "job=\"\${${array_name}[i]:-}\""
        [[ -n $job ]] && interleaved+=("$job")
    done
done


# Debug: show interleaved list
echo -e "\nInterleaved jobs (to be run by parallel):"
for job in "${interleaved[@]}"; do
    echo "  $job"
done

# Run the tasks in parallel
printf "%s\n" "${interleaved[@]}" | \
    parallel --ungroup -j50 --colsep ' ' translate_file {1} {2}
