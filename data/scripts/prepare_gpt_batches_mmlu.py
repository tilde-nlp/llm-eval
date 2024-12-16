import json
import os
from tqdm import tqdm


def prepare_batches(root_dir, en_file):
    # root_dir = "/data-7tb/martins-perkons/llm/llm-eval/mmlu/validation"
    # en_file = "m_mmlu_en/datasets/m_mmlu/en_val.json"

    lang_id = {"macedonian": "md",
               "estonian": "et",
               "lithuanian": "lt",
               "polish": "pl",
               "slovenian": "sl",
               "bulgarian": "bg",
               "croatian": "cr",
               "czech": "cz",
               "montenegrin": "cnr",
               "finnish": "fi",
               "latvian": "lv"
               }

    content = "Translate the values in the following JSON object into <target language> language. You must keep the keys in the JSON object in English. If a value contains programming code, only translate the comments while preserving the code. Your translations must convey all the content in the original text and cannot involve explanations or other unnecessary information. Please ensure that the translated text is natural for native speakers with correct grammar and proper word choices. Your translation must also use exact terminology to provide accurate information even for the experts in the related fields. Your output must only contain a JSON object with translated text and cannot include explanations or other information.\n"

    # Open the JSON file for reading

    with open(en_file, 'r', encoding='utf-8') as file:
        # Load the JSON data from the file into a Python dictionary
        data = json.load(file)

    for lang in lang_id:
        lang = lang.capitalize()

        local_content = content.replace("<target language>", lang)
        requests = []
        counter = 0

        for d in tqdm(data):
            og_answer = d["answer"]
            ind = d["id"]

            example = json.dumps(d)
            prompt = local_content + example

            custom_id = lang_id[lang.lower()] + "-" + str(counter) + "-ind-" + ind + "-label-" + og_answer

            request_dict = {"custom_id": custom_id, "method": "POST", "url": "/v1/chat/completions",
                            "body": {"model": "gpt-4o-mini",
                                     "messages": [{"role": "user", "content": prompt}], "temperature": 0}}

            requests.append(request_dict)

            counter += 1

        out_dir = root_dir + "/" + lang_id[lang.lower()]
        if not os.path.exists(out_dir):
            os.makedirs(out_dir)
        # Write each dictionary to a new line in the JSONL file
        with open(out_dir + "/" + lang_id[lang.lower()] + "-mmlu.jsonl", 'w', encoding='utf-8') as f:
            for item in requests:
                json_line = json.dumps(item)  # Convert dictionary to JSON string
                f.write(json_line + '\n')  # Write JSON string to file with a newline


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(
        description="Prepare batched translation requests for gpt-4o-mini. Source must be english MMLU JSON (e.g. from m_mmlu_en). Output will be split per language.")
    parser.add_argument("--in_path", required=True,
                        help="Path to output directory.")
    parser.add_argument("--source", default="m_mmlu_en/datasets/m_mmlu/en_val.json",
                        help="Source English MMLU JSON")

    args = parser.parse_args()

    prepare_batches(
        args.in_path,
        args.key
    )
