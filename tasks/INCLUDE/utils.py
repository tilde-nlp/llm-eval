
def doc_to_text(doc):
    return doc['question']

def doc_to_choice(doc):
    return [doc['option_a'], doc['option_b'], doc['option_c'], doc['option_d'] ]

def doc_to_target(doc):
    m = [doc['option_a'], doc['option_b'], doc['option_c'], doc['option_d'] ]
    return m[doc['answer']]
