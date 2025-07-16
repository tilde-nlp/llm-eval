from functools import partial

def convert_choice(choice):
    return choice[0].lower() + choice[1:]

def doc_to_text(doc, connector):
    question_type = doc["question"]
    if question_type == "cause":
        question = "Koji je razlog tome?"
    elif question_type == "effect":
        question = "Što se dogodilo kao rezultat?"
    else:
        raise ValueError(f"Unknown question type: {question_type}")

    premise = doc["premise"].strip()
    return f"Premise: {premise}\nQuestion: {question}"

#def doc_to_choice(doc):
#    return [convert_choice(doc["choice1"]), convert_choice(doc["choice2"])]
def doc_to_choice(doc):
    return [doc["choice1"], doc["choice2"]]
# You don't need connector in this format anymore, but keeping for compatibility
doc_to_text_id = partial(
    doc_to_text,
    connector=None,
)
