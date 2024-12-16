from openai import OpenAI
import os
from os import listdir
import json
from os.path import isfile, join


def queue_batches(root_dir, api_key):
    client = OpenAI(api_key=api_key, )

    # root_dir = "/data-7tb/martins-perkons/llm/llm-eval/mmlu/dev"
    file_paths = []
    for subdir, _, files in os.walk(root_dir):
        for file in files:
            # Construct full file path
            file_path = os.path.join(subdir, file)
            file_paths.append(file_path)

    # print(client.batches.list())
    print(file_paths)
    for file in file_paths:

        # dirty fix
        if "jsonl" not in file:
            continue
        print("Batching %s" % file)

        lang_root_dir = "/".join(file.split("/")[:-1])
        print(lang_root_dir)

        batch_input_file = client.files.create(
            file=open(file, "rb"),
            purpose="batch"
        )

        batch_input_file_id = batch_input_file.id
        print(batch_input_file_id)

        request = client.batches.create(
            input_file_id=batch_input_file_id,
            endpoint="/v1/chat/completions",
            completion_window="24h",
            metadata={
                "description": file.split("/")[-1]
            }
        )

        # store the request metadata for bookkeeping
        request_dict = vars(request)
        print(request_dict)
        with open(lang_root_dir + "/request.json", 'w', encoding='utf-8') as f:
            f.write(str(request_dict))


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(
        description="Pass prepared JSONL batch requests to OpenAPI. Store request metadata.")
    parser.add_argument("--in_path", required=True,
                        help="Path to the folder containing lang-id folders with prepared {lang-id}-{dset}.jsonl files containing translation prompts.")
    parser.add_argument("--key", required=True,
                        help="OpenAPI key")

    args = parser.parse_args()

    queue_batches(
        args.in_path,
        args.key
    )
