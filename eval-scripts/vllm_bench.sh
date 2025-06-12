lm_eval --model local-completions \
--tasks arcx_lv \
--num_fewshot 25 \
--batch_size 20 \
--output_path out_eurollm9bit_arc_lv_tlm.jsonl \
--model_args model=/local_data/martins/llm/hf_models/eurollm-9b,base_url=http://0.0.0.0:8001/v1/completions,num_concurrent=1,max_retries=3,tokenized_requests=False,request_timeout=300