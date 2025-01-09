CUDA_VISIBLE_DEVICES=0,1,2,3 accelerate launch --no-python --main_process_port 6969 lm_eval --model hf \
    --model_args "pretrained=utter-project/EuroLLM-1.7B" \
    --tasks mmlu_tlm_bg, mmlu_tlm_cnr, mmlu_tlm_cr, mmlu_tlm_cz, mmlu_tlm_et, mmlu_tlm_fi, mmlu_tlm_lt, mmlu_tlm_lv, mmlu_tlm_md, mmlu_tlm_pl, mmlu_tlm_sl \
    --num_fewshot 5 \
    --output_path out_eurollm_m_mmlu_okapi.jsonl \
    --batch_size auto