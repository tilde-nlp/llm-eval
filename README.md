## Installation

```git clone```

```git submodule init```

```git submodule update --init```

``` pip install -r requirements.txt ```

## Data

- ```raw/{lang-id}-{dset}.jsonl``` prepared batch inputs for OpenApi
- ```raw/{lang-id}/request.json``` OpenAPI batch processing request metadata
- ```raw/file-{request-id}.jsonl``` OpenApi batch output
- ```raw/{lang-id}-output.json``` parsed OpenAPI batch output, where broken json strings are removed
- ```raw/{lang-id}-output-converted.jsonl``` parsed json output converted to jsonl, where incomplete examples are removed
- ```clean/{lang-id}-output-clean.jsonl``` cleaned version of jsonl, where all languages are made to have the same amount of datapoints

## Benching

TODO: redo this with vllm
TODO: vllm - investigate batch size vs concurrency (currently concurrent setups sometimes time out and die)

Expected runtime ***per language*** using a single LUMI node (model parallelism=True and data parallelism=2) (x refers to open-gpt-x):

- Hellaswag(x) (batch=4) (10-shot) ~ 15 h
- MMLU(x) (batch=2) (5-shot) ~ 4 h
- ARC Easy(x) (batch=2/4) (25-shot) ~ 4 h 
- ARC Challenge(x) (batch=2/4) (25-shot) ~ 2h

***NOTE***: 
It is not trivial to see LUMI memory usage, so faster times are likely possible by maxing batch size. 
For this particular setup, using 'auto' for batch size results in OOM. Expected runtime is based on tqdm estimate, so it is more like an ***upper bound***.


## Tokenizer hack

When loading a model via lm-eval HF wrapper, the tokenizer is expected to have ***special_tokens_map.json*** and ***tokenizer_config.json*** files.
This is contrary to when loading via explicit HF call, where tokenizer config etc is somehow magically inferred or inherited from model's config.
To resolve this issue, run ***generate_tokenizer_files.py***

## TODO:

- EU20: move all dataset_path: openGPT-X/xxxx to Eurolingua/xxxx


