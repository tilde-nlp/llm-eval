import json
import os
import re


def process_documents(root_dir):
    # root_dir = "/data-7tb/martins-perkons/llm/llm-eval/mmlu/validation"
    # Specify input and output file paths
    # loop through stored requests and grab the correct response
    subfolders = [os.path.join(root_dir, o) for o in os.listdir(root_dir) if os.path.isdir(os.path.join(root_dir, o))]
    total_errors = 0
    total_lines = 0
    for folder in subfolders:

        # list all files
        files = [os.path.join(folder, o) for o in os.listdir(folder) if os.path.isfile(os.path.join(folder, o))]

        input_file = [f for f in files if "file-" in f and ".jsonl" in f][0]

        # Initialize a dict to hold the extracted JSON objects
        lang = ""
        content_list = {}
        errors = 0

        # Read the JSONL file
        with open(input_file, 'r', encoding='utf-8') as f:
            for line_number, line in enumerate(f, start=1):
                line = line.strip()
                if line:
                    total_lines += 1
                    try:
                        # Load the JSON object from the line
                        obj = json.loads(line)

                        idd = obj["custom_id"]
                        num = int(idd.split("-")[1])
                        lang_id = idd.split("-")[0]

                        # Access the nested content field
                        content_str = obj['response']['body']['choices'][0]['message']['content']
                        content_str = content_str.replace("```json", "").replace("```", "")
                        # remove trailing comas?
                        # fixme: this wont work for hellaswag
                        # content_str = re.sub(r',\s*([\}\]])', r'\1', content_str)
                        # fixme: can use this for hellaswag, but seems quite useless
                        # content_str = re.sub(r'(?<!\\)\n', r'\\n', content_str)

                        # Parse the content string into a dictionary
                        content_dict = json.loads(content_str)
                        if lang == "":
                            lang = lang_id

                        # Append the parsed content to the list
                        content_list[num] = content_dict
                    except (KeyError, IndexError, json.JSONDecodeError) as e:
                        errors += 1
                        print(f"Error processing line {line_number}: {e}")
                        # print(content_str)
                        # print(repr(content_str))
                        # fixme: this worked for some of the datasets but not for all
                        # print(content_str.replace("```json", "").replace("```", ""))
                        # ls = json.loads(content_str.replace("```json", "").replace("```", ""))
                        # print("Conversion succesfull")
                        # print(ls)
                        # Optionally, skip this line or handle the error as needed
                        continue  # Skip this line and proceed to the next

        output_file = folder + "/" + lang + "-output.json"

        # Write the extracted content to a JSON file with Unicode characters
        with open(output_file, 'w', encoding='utf-8') as f:
            content_list_clean = []
            for i in sorted(list(content_list.keys())):
                content_list_clean.append(content_list[i])
            json.dump(content_list, f, ensure_ascii=False, indent=4)

        total_errors += errors

        print("Processed %s" % input_file)
        print("Wrote output to %s" % output_file)
        print("Errors: %s" % errors)

    print()
    print("Finished. Total errors: %s/%s" % (total_errors, total_lines))


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(
        description="Parse nested JSONL chatGPT requests output into JSON. Discard faulty generated JSON strings.")
    parser.add_argument("--in_path", required=True,
                        help="Path to the folder containing lang-id folders with file-{xxxx}.jsonl chatGPT batch output files")

    args = parser.parse_args()

    process_documents(
        args.in_path
    )
