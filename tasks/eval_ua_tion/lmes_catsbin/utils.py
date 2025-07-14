def doc_to_text(doc):
    return doc['question']

def doc_to_target(doc):
    r = {True: 'правда',
         False : 'хиба'}
    return r[doc['correctAnswer']]


def doc_to_choice(doc):
    return ['правда', 'хиба']