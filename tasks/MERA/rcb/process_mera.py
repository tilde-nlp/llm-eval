def doc_to_text(doc):
    instruction = doc["instruction"].strip()
    return instruction.format(premise=doc["inputs"]["premise"], hypothesis= doc["inputs"]["hypothesis"])

def doc_to_choice(doc):
    return ["1", "2", "3",]
