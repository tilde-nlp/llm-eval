def doc_to_text(doc):
    return f'{doc['context']}\n{doc['question']}\n\nможливі відповіді: {doc['options']}\n\nвідповідь: '