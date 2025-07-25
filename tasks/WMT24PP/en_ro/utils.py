
from datasets import Dataset

def filter_data(dataset):
    return dataset.filter(lambda doc: not doc.get('is_bad_source', False))

def doc_to_text(doc):
    docs = doc['source']
    return (f"Translate the text given in English to Romanian:"
            f"\n"
            f"{docs}"
            f"\n\n")

def doc_to_target(doc):
    return doc['target']
