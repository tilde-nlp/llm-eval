def doc_to_text(doc):
    return doc["inputs"]

def doc_to_choice(doc):
    return doc["multiple_choice_targets"]


def doc_to_target(doc):
    return doc["targets"][0]
