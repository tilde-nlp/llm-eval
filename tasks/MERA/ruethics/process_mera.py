

def doc_to_text(doc):
    instruction = doc["instruction"].strip()
    return instruction.format(text=doc["inputs"]["text"], actant_1= doc["inputs"]["actant_1"], actant_2= doc["inputs"]["actant_2"])
def doc_to_target(doc):
    return doc["outputs"]["moral"]
def doc_to_choice(doc):
    """
    Returns a list of all options in the order A-D.
    """
    options = doc["inputs"]
    return [
        options["actant_1"],
        options["actant_2"],
    ]
