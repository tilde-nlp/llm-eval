def doc_to_text(doc):
    return f"{doc['question']}\n\nтак чи ні?"

def doc_to_target(doc):
    r = {True: 'так',
         False : 'ні'}
    return r[doc['correctAnswer']]


def doc_to_choice(doc):
    return ['так', 'ні']