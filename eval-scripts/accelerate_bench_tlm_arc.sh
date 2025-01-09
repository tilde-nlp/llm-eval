CUDA_VISIBLE_DEVICES=0,1,2,3 accelerate launch --no-python --main_process_port 6969 lm_eval --model hf \
    --model_args "pretrained=utter-project/EuroLLM-1.7B" \
    --tasks arc_tlm_bg, arc_tlm_cnr, arc_tlm_cr, arc_tlm_cz, arc_tlm_et, arc_tlm_fi, arc_tlm_lt, arc_tlm_lv, arc_tlm_md, arc_tlm_pl, arc_tlm_sl \
    --num_fewshot 25 \
    --output_path out_eurollm_arc_tlm.jsonl \
    --batch_size auto