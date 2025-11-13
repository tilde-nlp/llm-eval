def doc_to_text(doc):
    instruction = doc["instruction"].strip()
    return instruction.format(text=doc["inputs"]["text"], support_text=doc["inputs"]["support_text"], question=doc["inputs"]["question"])