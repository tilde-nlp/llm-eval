def doc_to_text(doc):
    instruction = doc["instruction"].strip()
    return instruction.format(query=doc["inputs"]["query"], reply_1= doc["inputs"]["reply_1"], reply_2= doc["inputs"]["reply_2"])
def doc_to_choice(doc):
    """
    Returns a list of all options in the order A-D.
    """
    options = doc["inputs"]
    return [
        options["reply_1"],
        options["reply_2"],
    ]
