#!/usr/bin/env bash
set -euo pipefail

# ---------- rank → GPUs / port --------------------------------------------
RANK=$1         # 0-7 within the node
PORT=$2         # 8000, 8001, etc

GPU0=$(( RANK * 2 ))              # 0,2,4,6
GPU1=$(( GPU0 + 1 ))              # 1,3,5,7

export CUDA_VISIBLE_DEVICES=$GPU0,$GPU1

echo "[task $RANK] → GPUs $GPU0,$GPU1  TP=$TP  port $PORT"

singularity exec --rocm \
  -B "$MODEL_DIR":"$MODEL_DIR" \
  -B "$(pwd)/run_vllm.sh":/run_vllm.sh \
  "$SIF" \
  /run_vllm.sh "$PORT" "$TP" "$MODEL_DIR" "$TOKENIZER" "$TOKENIZER_MODE" # these are in fact exported as global variables
