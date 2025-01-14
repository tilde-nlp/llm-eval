CUDA_VISIBLE_DEVICES=0,1,2,3,4,5,6,7 lm_eval --model hf \
    --model_args "pretrained=/tmp/martins/llm_dir/full_test_hf,parallelize=True,trust_remote_code=True" \
    --tasks hellaswagx_lv \
    --num_fewshot 10 \
    --batch_size 2
