
from evaluate import load
def doc_to_text(doc):
    lines = doc["reference"].splitlines()
    cleaned_lines = lines[2:]
    sec_text = '\n'.join(cleaned_lines).strip()
    return (f"Sintetize o texto:"
            f"\n"
            f"{sec_text}"
            f"\n\n")
            

def doc_to_target(doc):
    target_text_second = doc['summary']
    return (f"Resumo:"
            f"\n"
            f"{target_text_second}"
            )
def process_results(doc, prediction):
    rouge = load("rouge")
    # Evaluate single-pair summary
    results = rouge.compute(predictions=[prediction], references=[doc["summary"]], use_stemmer=True)
    inside_process_function = {"rouge1": results["rouge1"], "rouge2": results["rouge2"], "rougeL": results["rougeL"]}
    return f"{inside_process_function}"
