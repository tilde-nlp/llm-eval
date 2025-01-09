CUDA_VISIBLE_DEVICES=0,1,2,3 accelerate launch --no-python --main_process_port 6969 lm_eval --model hf \
    --model_args "pretrained=utter-project/EuroLLM-1.7B" \
    --tasks hellaswag_tlm_bg, hellaswag_tlm_cnr, hellaswag_tlm_cr, hellaswag_tlm_cz, hellaswag_tlm_et, hellaswag_tlm_fi, hellaswag_tlm_lt, hellaswag_tlm_lv, hellaswag_tlm_md, hellaswag_tlm_pl, hellaswag_tlm_sl \
    --num_fewshot 10 \
    --output_path out_eurollm_hellaswag_okapi.jsonl \
    --batch_size auto