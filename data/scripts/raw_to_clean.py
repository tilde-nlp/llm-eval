import os
import json


from collections import Counter

def find_common_elements(lists):
    """
    Find elements that occur in all lists while preserving the order of the first list.

    Args:
        lists (list of lists): A list containing multiple lists.

    Returns:
        list: Elements that appear in all lists, in the order of the first list.
    """
    # Start by taking the first list
    first_list = lists[0]

    # Create a set for each list to remove duplicates within individual lists
    sets = [set(lst) for lst in lists]

    # Find the intersection of all sets (common elements)
    common_elements = set.intersection(*sets)

    # Preserve order: filter the first list to retain only common elements
    result = [item for item in first_list if item in common_elements]

    return result

d = "C:/Users/martins.kuznecovs/PycharmProjects/llm-eval/data/hellaswag_tlm/raw"

if "hellaswag" in d:
    splits = [d]
else:
    splits = [os.path.join(d, o) for o in os.listdir(d)
              if os.path.isdir(os.path.join(d, o))]

print(splits)

for split in splits:
    langs = [os.path.join(split, o) for o in os.listdir(split)
             if os.path.isdir(os.path.join(split, o))]

    all_ids = []
    # print(split)
    # print(langs)
    for n, lang in enumerate(langs):
        lang_id = lang.split("\\")[-1]
        # print(lang_id)
        seen_ids = []
        with open(lang + "/" + lang_id + "-output-converted.jsonl", 'r', encoding='utf-8') as in_f:
            lines = in_f.readlines()
            for line in lines:
                line = line.strip()
                if line == "":
                    continue
                data = json.loads(line)
                try:
                    idd = data["id"]
                except KeyError:
                    continue

                if idd not in seen_ids:
                    seen_ids.append(idd)

        all_ids.append(seen_ids)

    filtered_ids = find_common_elements(all_ids)
    # make sure that ids are consistent across all languages (remove examples that do not appear in all langs)
    print("--------- %s -----------" % split)
    for lang in langs:
        lang_id = lang.split("\\")[-1]

        discarded = 0
        total = 0
        with open(lang + "/" + lang_id + "-output-converted.jsonl", 'r', encoding='utf-8') as in_f:
            lines = in_f.readlines()

            out_lang = lang.replace("raw", "clean")
            os.makedirs(out_lang, exist_ok=True)

            with open(out_lang + "/" + lang_id + "-output-clean.jsonl", 'w', encoding='utf-8') as out_f:

                for line in lines:
                    line = line.strip()
                    if line == "":
                        continue

                    data = json.loads(line)
                    try:
                        idd = data["id"]
                    except KeyError:
                        continue
                    if idd in filtered_ids:

                        out_f.write(json.dumps(data, ensure_ascii=False) + '\n')
                        dummy = 1
                    else:
                        discarded += 1

                    total += 1

        print("For %s , discarded [%s/%s] %s%s" % (lang_id, discarded, total, round(100 * discarded / total, 2), "%"))
