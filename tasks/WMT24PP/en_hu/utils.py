
from sacrebleu.metrics import BLEU
import os
os.environ["HF_HUB_DISABLE_SYMLINKS_WINDOWS"] = "1"

bleu = BLEU()

def clean_doc(doc):
    # Remove auto-generated pandas index column if it exists
    if '__index_level_0__' in doc:
        del doc['__index_level_0__']
    return doc

def doc_to_text(doc):
    doc = clean_doc(doc)
    docs = doc['source']
    return (f"Translate the text given in English to Hungarian:
"
            f"{docs}

")

def doc_to_target(doc):
    doc = clean_doc(doc)
    return doc['target']

def process_results(doc, results):
    doc = clean_doc(doc)
    prediction = results[0]
    reference = doc_to_target(doc)
    score = bleu.sentence_score(prediction.strip(), [reference.strip()]).score
    return score

