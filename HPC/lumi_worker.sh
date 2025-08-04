#!/bin/bash

#SBATCH --account project_465001281
#SBATCH --partition dev-g
#SBATCH --exclusive=user
#SBATCH --nodes=1
#SBATCH --gpus-per-node=mi250:8
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=56
#SBATCH --mem=0
#SBATCH --time=3:00:00
#SBATCH --hint=nomultithread
#SBATCH --job-name=vllm-4x2

export CC=gcc-12
export CXX=g++-12

# --- modules ---------------------------------------------------------------
module purge
module load CrayEnv
module load LUMI/24.03
module load partition/G
module load rocm/6.2.2
module load gcc/12.2.0
module load parallel/20240522

module use /appl/local/training/modules/AI-20240529/
module load singularity-userfilesystems

# sanity check
which parallel >/dev/null || { echo "parallel not in PATH"; exit 1; }


#Don't fully understand.
#Necessary for faster internode communication.
export NCCL_SOCKET_IFNAME=hsn0,hsn1,hsn2,hsn3

#Don't understand. Necessary for faster internode communication, I think.
export OMP_NUM_THREADS=1

#Don't understand. Necessary for faster memory access between nodes, I think.
export NCCL_NET_GDR_LEVEL=PHB

#A variety of debug output flags.
#Hasn't really helped me much.
#export NCCL_DEBUG=INFO
#export RCCL_KERNEL_COLL_TRACE_ENABLE=1
#export NCCL_DEBUG_SUBSYS=INIT,COLL

#Not sure if this is necessary.
#I think this was copied over from one of SILO.AIs configs.
mkdir -p workdir
wd=$(realpath workdir)
if [ ! -d "$wd"/cray-deps ] ; then
  rm -rf "$wd"/cray-deps
  mkdir "$wd"/cray-deps
  cp /usr/lib64/libcxi* $wd/cray-deps
fi

# --- where the container & model live --------------------------------------
SCRATCH=/scratch/project_465001281/MK/vllm
SIF=$SCRATCH/vllm_local_2
#MODEL_DIR=$SCRATCH/models/gemma-2-27b-it

#MODEL_DIR=/scratch/project_465001281/MK/checkpoints/final_train_converted/LATEST_translate_instruct_low_LR_no_optim_100m-mix_filtered_423958

# MODEL_DIR=/scratch/project_465001281/MK/checkpoints/final_train_converted/LATEST_translate_instruct_low_LR_no_optim_100m-mix_super_filtered_423958
# TOKENIZER=/scratch/project_465001281/MK/vllm/vllm2_martins/4b_tokenizer_debug # == MODEL_DIR, if not TILDELM
# TOKENIZER_MODE="slow"  # slow - for TILDELM, auto for almost everything else

# --- euro lm 9b it
# MODEL_DIR=/scratch/project_465001281/MK/vllm/models/eurollm-9b-it
# TOKENIZER=/scratch/project_465001281/MK/vllm/models/eurollm-9b-it
# TOKENIZER_MODE="auto"

# --- euro lm 22b it
#MODEL_DIR=/scratch/project_465001281/MK/vllm/models/eurollm-22b-it-preview
#TOKENIZER=/scratch/project_465001281/MK/vllm/models/eurollm-22b-it-preview
#TOKENIZER_MODE="auto"

# --- tower lm
MODEL_DIR=/scratch/project_465001281/MK/vllm/models/tower-plus-72b
TOKENIZER=/scratch/project_465001281/MK/vllm/models/tower-plus-72b
TOKENIZER_MODE="auto"

export MODEL_DIR
export SIF
export SCRATCH
export TOKENIZER
export TOKENIZER_MODE

# --- some VLLM config stuff ---
export VLLM_USE_TRITON_FLASH_ATTN=0

###############################################################################
# 0.  Handle args
###############################################################################
set -euo pipefail

# Require at least 2 arguments
[[ $# -lt 2 ]] && { echo "Usage: $0 DATA_DIR NUM_INSTANCES [MODEL_TYPE] [FEW_SHOT_FILE] [N_FEW_SHOT]"; exit 1; }

DATA_DIR="${1%/}"  # remove trailing slash
NUM_INSTANCES="$2"
MODEL_TYPE="${3:tildelm}"
FEW_SHOT_FILE="${4:file_not_provided}"
N_FEW_SHOT="${5:-}"

# mandatory args
[[ ! -d "$DATA_DIR" ]] && { echo "DATA_DIR not found: $DATA_DIR"; exit 1; }
# Validate NUM_INSTANCES
if [[ ! "$NUM_INSTANCES" =~ ^(1|2|4|8)$ ]]; then
  echo "NUM_INSTANCES must be one of: 1, 2, 4, or 8"
  exit 1
fi

# optional args
# allowed model types (space-separated)
ALLOWED_MODELS="tildelm eurollm gemma tower llama"

if [[ -n "$MODEL_TYPE" && ! " $ALLOWED_MODELS " =~ " $MODEL_TYPE " ]]; then
  echo "Invalid MODEL_TYPE: '$MODEL_TYPE'. Must be one of: $ALLOWED_MODELS"
  exit 1
fi

# few-shot config
if [[ -n "$FEW_SHOT_FILE" ]]; then
  [[ ! -f "$FEW_SHOT_FILE" ]] && { echo "Few-shot file not found: $FEW_SHOT_FILE"; exit 1; }
  [[ -z "$N_FEW_SHOT" ]] && N_FEW_SHOT=1
else
  N_FEW_SHOT=0
fi

[[ ! "$N_FEW_SHOT" =~ ^[0-9]+$ ]] && { echo "N_FEW_SHOT must be a non-negative integer"; exit 1; }

# export python related args as globals for later use
export FEW_SHOT_FILE
export N_FEW_SHOT
export MODEL_TYPE

###############################################################################
# 1.  Figure out which source files still need work
###############################################################################

pending=()
for f in "$DATA_DIR"/*.jsonl; do
    [[ "$f" == *.translated.jsonl ]] && continue         # skip translated files
    [[ -f "${f}.translated.jsonl" ]] && continue         # skip if already translated
    [[ -f "${f}.done" ]] && continue                     # skip if already marked done
    pending+=( "$f" )
done

echo "→ ${#pending[@]} file(s) still need translation"

if [[ ${#pending[@]} -eq 0 ]]; then
    echo "Everything already translated — exiting."
    exit 0
fi


###############################################################################
# 3.  Work on the remaining files in this job
###############################################################################
files=( "${pending[@]}" )
total=${#files[@]}

# ── 3a. Start a vLLM server on evey 2  GPUs ───────────────────────────────────────

# Calculate TP (Tensor Parallelism)
TP=$((8 / NUM_INSTANCES))
export TP

# Construct PORTS and RANKS arrays
PORTS=()
RANKS=()
BASE_PORT=8000

for ((i=0; i<NUM_INSTANCES; i++)); do
  PORTS+=($((BASE_PORT + i)))
  RANKS+=($i)
done

echo "Available ranks: ${RANKS[*]}"
echo "Available ports: ${PORTS[*]}"

# ── Start a vLLM server on each x GPU ───────────────────────────────────────────────
for idx in "${!RANKS[@]}"; do
  RANK=${RANKS[$idx]}
  PORT=${PORTS[$idx]}
  echo "→ Launching rank $RANK on port $PORT"
  sleep 2
  ./launch_rank.sh $RANK $PORT &
done

bash ./launch_client.sh "$total" "${files[@]}" "${PORTS[@]}"
