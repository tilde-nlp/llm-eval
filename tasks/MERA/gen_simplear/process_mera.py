def doc_to_text(doc):
    instruction = doc["instruction"].strip()
    return instruction.format(inputs=doc["inputs"])