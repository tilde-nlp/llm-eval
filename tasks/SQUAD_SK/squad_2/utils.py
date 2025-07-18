def doc_to_text(doc):
    return f"Kontext:\n{doc["context"]}\n\nOtázka:\n{doc['question']}"

def doc_to_target(doc):
    texts = doc.get("answers", {}).get("text", [])
    return texts[0] if texts else ""
