def doc_to_text(doc):
    instruction = doc["instruction"].strip()
    return instruction.format(toxic_comment=doc["inputs"])