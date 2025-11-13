def doc_to_text(doc):
    instruction = doc["instruction"].strip()
    return instruction.format(text=doc["inputs"]["text"], task=doc["inputs"]["task"], choices=doc["inputs"]["choices"], additional_text=doc["inputs"]["additional_text"])