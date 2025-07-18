def doc_to_text(doc):
    return (f'Kontekst: {doc['data']['context']} '
            f' '
            f'Küsimus: {doc['data']['question']} '
            f'Vastus: ')

def doc_to_target(doc):
    return doc['data']['answers']['text'][0]