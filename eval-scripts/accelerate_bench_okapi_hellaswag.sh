CUDA_VISIBLE_DEVICES=0,1,2,3 accelerate launch --no-python --main_process_port 6969 lm_eval --model hf \
    --model_args "pretrained=utter-project/EuroLLM-1.7B" \
    --tasks hellaswag_de,hellaswag_fr,hellaswag_es,hellaswag_it,hellaswag_pt,hellaswag_ru,hellaswag_nl,hellaswag_ar,hellaswag_sv,hellaswag_hi,hellaswag_hu,hellaswag_ro,hellaswag_uk,hellaswag_da \
    --num_fewshot 10 \
    --output_path out_eurollm_hellaswag_okapi.jsonl \
    --batch_size auto