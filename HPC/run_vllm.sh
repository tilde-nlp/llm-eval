#!/usr/bin/env bash
set -euo pipefail

# --- args handed in from srun ---------------------------------------------
PORT=$1          # 8000-8003
TP=$2            # tensor-parallel size (2)
MODEL_DIR=$3     # exported as global, but arg functionality is kept for later usage
TOKENIZER=$4     # exported as global, but arg functionality is kept for later usage
TOKENIZER_MODE=$5 # exported as global, but arg functionality is kept for later usage

# --- environment inside the container -------------------------------------
$WITH_CONDA
export PYTHONNOUSERSITE=1 # <- do not use /usr/local, use only what is inside the container

exec python -m vllm.entrypoints.openai.api_server \
     --model "$MODEL_DIR" \
     --trust-remote-code \
     --tokenizer "$TOKENIZER" \
     --tokenizer-mode "$TOKENIZER_MODE" \
     --dtype "bfloat16" \
     --tensor-parallel-size "$TP" \
     --max-model-len 8192 \
     --port "$PORT" \
     --host 0.0.0.0 \
     --gpu-memory-utilization 0.9
