def doc_to_text(doc):
    return f'{doc['context']}\n{doc['question']}\n\n'

def doc_to_target(doc):
    return doc["answers"]['text'][0]
