CUDA_VISIBLE_DEVICES=0,1,2,3 accelerate launch --no-python --main_process_port 6969 lm_eval --model hf \
    --model_args "pretrained=utter-project/EuroLLM-1.7B" \
    --tasks arc_de,arc_fr,arc_es,arc_it,arc_pt,arc_ru,arc_nl,arc_ar,arc_sv,arc_hi,arc_hu,arc_ro,arc_uk,arc_da \
    --num_fewshot 25 \
    --output_path out_eurollm_arc_okapi.jsonl \
    --batch_size auto