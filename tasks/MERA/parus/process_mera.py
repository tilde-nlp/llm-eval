def doc_to_text(doc):
    instruction = doc["instruction"].strip()
    return instruction.format(premise=doc["inputs"]["premise"], choice1= doc["inputs"]["choice1"], choice2= doc["inputs"]["choice2"])

def doc_to_choice(doc):
    """
    Returns a list of all options in the order A-D.
    """
    options = doc["inputs"]
    return [
        options["choice1"],
        options["choice2"],
    ]
