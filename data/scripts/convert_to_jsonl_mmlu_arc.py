import json
import os


def process_documents(root_dir):
    # root_dir = "/data-7tb/martins-perkons/llm/llm-eval/mmlu/test"

    # loop through lang-di subfolders
    subfolders = [os.path.join(root_dir, o) for o in os.listdir(root_dir) if os.path.isdir(os.path.join(root_dir, o))]
    for folder in subfolders:

        # list all files
        files = [os.path.join(folder, o) for o in os.listdir(folder) if os.path.isfile(os.path.join(folder, o))]

        input_file = [f for f in files if "-output." in f and ".json" in f][0]

        output_file = input_file.replace(".json", ".jsonl")
        output_file = output_file.replace("-output", "-output-converted")

        print("Parsing %s ..." % input_file)
        # Read the JSON file
        broken = 0
        total = 0
        with open(input_file, 'r', encoding='utf-8') as f:
            with open(output_file, 'w', encoding='utf-8') as f_out:
                json_in = json.load(f)

                for example in json_in:
                    datapoint = json_in[example]
                    total += 1

                    # Each MMLU or ARC datapoint must have 7 entries
                    if len(datapoint) < 7:
                        broken += 1
                        continue

                    json_line = json.dumps(datapoint, ensure_ascii=False)  # Convert dictionary to JSON string
                    f_out.write(json_line + '\n')  # Write JSON string to file with a newline

        print("Finished processing. Incomplete examples: %s/%s %s%s" % (
            broken, total, round(100 * broken / total, 2), "%"))


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Convert JSON corpus to JSONL. Discard faulty datapoints.")
    parser.add_argument("--in_path", required=True,
                        help="Path to the folder containing lang-id folders with {lang-id}-output.jsonl files")

    args = parser.parse_args()

    process_documents(
        args.in_path
    )
