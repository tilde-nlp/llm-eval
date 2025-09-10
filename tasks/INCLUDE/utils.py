
def doc_to_text(doc):
    return f"{doc['question']}\n{doc['option_a']}\n{doc['option_b']}\n{doc['option_c']}\n{doc['option_d']}\n\n"

def doc_to_choice(doc):
    return [doc['option_a'], doc['option_b'], doc['option_c'], doc['option_d']]

def doc_to_target(doc):
    m = [doc['option_a'], doc['option_b'], doc['option_c'], doc['option_d']]
    return m[doc['answer']]
