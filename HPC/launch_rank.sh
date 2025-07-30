#!/usr/bin/env bash
set -euo pipefail

# ---------- rank → GPUs / port --------------------------------------------
RANK=$1         # 0-3 within the node

GPU0=$(( RANK * 2 ))              # 0,2,4,6
GPU1=$(( GPU0 + 1 ))              # 1,3,5,7
PORT=$(( 8000 + RANK ))

export CUDA_VISIBLE_DEVICES=$GPU0,$GPU1

echo "[task $RANK] → GPUs $GPU0,$GPU1  TP=2  port $PORT"

singularity exec --rocm \
  -B "$MODEL_DIR":"$MODEL_DIR" \
  -B "$(pwd)/run_vllm.sh":/run_vllm.sh \
  "$SIF" \
  /run_vllm.sh "$PORT" 2 "$MODEL_DIR" "$TOKENIZER" "$TOKENIZER_MODE" # these are in fact exported as global variables
