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

## Tokenizer hack

When loading via lm-eval HF wrapper, the tokenizer is expected to have ***special_tokens_map.json*** and ***tokenizer_config.json*** files.
This is contrary to when loading via explicit HF call, where config etc is somehow magically inferred or inherited from model's config.
To resolve this issue, run     ..... some conversion script ......