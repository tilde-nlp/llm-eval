#!/usr/bin/env bash
set -euo pipefail

# ---------- rank → GPUs / port --------------------------------------------
RANK=$1         # 0-7 within the node
PORT=$2         # 8000, 8001, etc

# TP is exported globally
# GPUs per instance = 8 / TP
GPUS_PER_INSTANCE=$TP
START_GPU=$(( RANK * GPUS_PER_INSTANCE ))

# Build the CUDA_VISIBLE_DEVICES string
DEVICES=()
for ((i=0; i<GPUS_PER_INSTANCE; i++)); do
  DEVICES+=($((START_GPU + i)))
done

export CUDA_VISIBLE_DEVICES=$(IFS=, ; echo "${DEVICES[*]}")

echo "[task $RANK] → GPUs ${CUDA_VISIBLE_DEVICES}  TP=$TP  port $PORT"

singularity exec --rocm \
  -B "$MODEL_DIR":"$MODEL_DIR" \
  -B "$(pwd)/run_vllm.sh":/run_vllm.sh \
  "$SIF" \
  /run_vllm.sh "$PORT" "$TP" "$MODEL_DIR" "$TOKENIZER" "$TOKENIZER_MODE" # these are in fact exported as global variables
