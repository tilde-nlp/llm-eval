def doc_to_text(doc):
    instruction = doc["instruction"].strip()
    return instruction.format(text=doc["inputs"]["text"], span1_text= doc["inputs"]["span1_text"], span2_text= doc["inputs"]["span2_text"])

def doc_to_choice(doc):
    return ["Да", "Нет",]
