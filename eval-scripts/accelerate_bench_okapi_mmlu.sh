CUDA_VISIBLE_DEVICES=0,1,2,3 accelerate launch --no-python --main_process_port 6969 lm_eval --model hf \
    --model_args "pretrained=utter-project/EuroLLM-1.7B" \
    --tasks m_mmlu_de,m_mmlu_fr,m_mmlu_es,m_mmlu_it,m_mmlu_pt,m_mmlu_ru,m_mmlu_nl,m_mmlu_ar,m_mmlu_sv,m_mmlu_hi,m_mmlu_hu,m_mmlu_ro,m_mmlu_uk,m_mmlu_da \
    --num_fewshot 5 \
    --output_path out_eurollm_m_mmlu_okapi.jsonl \
    --batch_size auto