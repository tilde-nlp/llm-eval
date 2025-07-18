def doc_to_text(doc):
    instruction = doc["instruction"].strip()
    return instruction.format(text=doc["inputs"]["text"], topic=doc["inputs"]["topic"])