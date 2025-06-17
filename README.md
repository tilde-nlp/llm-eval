## Installation

```
git clone https://github.com/tilde-nlp/llm-eval.git
git submodule init
git submodule update --init
pip install -r requirements.txt
```
#### Install lm-eval command line tools

``` 
cd lm-evaluation-harness 
pip install -e .
```


## TLM translated data

- ```raw/{lang-id}-{dset}.jsonl``` prepared batch inputs for OpenApi
- ```raw/{lang-id}/request.json``` OpenAPI batch processing request metadata
- ```raw/file-{request-id}.jsonl``` OpenApi batch output
- ```raw/{lang-id}-output.json``` parsed OpenAPI batch output, where broken json strings are removed
- ```raw/{lang-id}-output-converted.jsonl``` parsed json output converted to jsonl, where incomplete examples are removed
- ```clean/{lang-id}-output-clean.jsonl``` cleaned version of jsonl, where all languages are made to have the same amount of datapoints

## Benching [OUTDATED]

Expected runtime ***per language*** using a single LUMI node (model parallelism=True and data parallelism=2) (x refers to open-gpt-x):

- Hellaswag(x) (batch=4) (10-shot) ~ 15 h
- MMLU(x) (batch=2) (5-shot) ~ 4 h
- ARC Easy(x) (batch=2/4) (25-shot) ~ 4 h 
- ARC Challenge(x) (batch=2/4) (25-shot) ~ 2h

***NOTE***: 
It is not trivial to see LUMI memory usage, so faster times are likely possible by maxing batch size. 
For this particular setup, using 'auto' for batch size results in OOM. Expected runtime is based on tqdm estimate, so it is more like an ***upper bound***.


## Tokenizer hack [OUTDATED]

When loading a model via lm-eval HF wrapper, the tokenizer is expected to have ***special_tokens_map.json*** and ***tokenizer_config.json*** files.
This is contrary to when loading via explicit HF call, where tokenizer config etc is somehow magically inferred or inherited from model's config.
To resolve this issue, run ***generate_tokenizer_files.py***

## TODO:

- EU20: move all dataset_path: openGPT-X/xxxx to Eurolingua/xxxx
- Redo all benches with vllm, measure speed vs accelerate
- vllm - investigate batch size vs concurrency (currently concurrent setups sometimes time out and die)

## New task guide

- Refer to [LM Evaluation harness docs](https://github.com/EleutherAI/lm-evaluation-harness/tree/main/docs) for general information about adding new tasks.
- _Make sure that you are familiar with what most keys do in the yaml config files._

### General rules

- New tasks should be added to repo root **task** folder.
- Use copy_tasks.sh to place them into lm-eval submodule during runtime. 
- DO NOT commit any files into lm-eval submodule.
- Scripts related to creating this task should be added to [TBD]

### Debug tools

```bash
python lm-evaluation-harness/scripts/write_out.py
    --tasks arcx_lv \
    --num_fewshot 1 \
    --num_examples 2 \
    --output_base_path .
```

This will download and/or load your task and prepare the data exactly as it will be fed into the model. 
If anything is wrong with task configuration it will throw errors that will guide you in the correct direction.
Always inspect the written output and see if it looks like you think the model should be prompted for this task.
Once this script completes without errors and you are satisfied with the generated output, you can proceed to actually running the task.

### Adding a task X that has the data hosted on HF

1. Find the (most) similar task to task X that currently exists in LM Evaluation harness (task Y)
2. Inspect how task Y dataset is hosted on huggingface ("dataset_path:" in yaml) and compare to task X:
   - If the data appears **identical** in structure, you are quite safe to assume that you can just copy the **yaml files** and **utils.py** from task Y to a new folder and adjust just a few keys.
   - If there is **divergence**, then try to re-use the **yaml files** and **utils.py** from task Y and proceed by fixing any errors. Configuration errors are usually addressed by changing yaml keys, and formatting issues can usually be adressed by modifiying utils.
3. Once write_out.py succeeds, try to run the task X on the reference model from task's publication. If there is huge discrepancy - debug.
4. Each task should be added via a separate branch and PR. 
5. Task PR should include:
   - the task folder (with yaml and utils.py)
   - any scripts that were used to auto generate yaml files (also organised somewhere [TBD])
   - task_name.md that contains some description (publication ideally is linked) and bench results vs the reference model. It should also contain the written output from write_out.py. Instructions how to run benches with this task.

### Adding a task X that has local data

1. Panic