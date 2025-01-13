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
        out_doc = {
            "id": doc["id"],
            "query": "Question: " + preprocess(doc["question"]) + "\nAnswer:",
            "choices": [
                preprocess(option)
                for option in doc["choices"]["text"]
                if option
            ],
            "gold": doc["choices"]["label"].index(doc["answerKey"]),
        }
        return out_doc

    return dataset.map(_process_doc)
