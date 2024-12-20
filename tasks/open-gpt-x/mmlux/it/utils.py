import re

import datasets


def preprocess(text):
    text = text.strip()
    text = text.replace(" [title]", ". ")
    text = re.sub("\\[.*?\\]", "", text)
    text = text.replace("  ", " ")
    return text


def process_docs(dataset: datasets.Dataset) -> datasets.Dataset:
    def _process_doc(doc):
        # breakpoint()
        print(doc)
        out_doc = {
            "id": doc["id"],
            "query": doc["question"].strip() + "\nA. " + doc["choices"][0] + "\nB. " + doc["choices"][1] + "\nC. " + doc["choices"][2] + "\nD. " + doc["choices"][3] + "\nAnswer:",
            "choices": doc["choices"],
            "gold": ["A", "B", "C", "D"][int(doc["answer"])],
        }
        return out_doc

    return dataset.map(_process_doc)
