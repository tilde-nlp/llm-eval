def doc_to_text(doc):
    instruction = doc["instruction"].strip()
    return instruction.format(question=doc["inputs"]["question"], option_a= doc["inputs"]["option_a"], option_b= doc["inputs"]["option_b"],option_c= doc["inputs"]["option_c"],option_d = doc["inputs"]["option_d"])


def doc_to_choice(doc):
    """
    Returns a list of all options in the order A-D.
    """
    options = doc["inputs"]
    return [
        options["option_a"],
        options["option_b"],
        options["option_c"],
        options["option_d"],
    ]
