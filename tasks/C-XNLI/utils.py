def doc_to_text(doc):
    return f"Premise: {doc["premise"]}\nHypothesis: {doc["hypo"]}"

def doc_to_choice(doc):
    return ["entailment", "contradiction", "neutral"]