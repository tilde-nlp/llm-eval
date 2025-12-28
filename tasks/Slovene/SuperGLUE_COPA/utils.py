from functools import partial

def convert_choice(choice):
    return choice[0].lower() + choice[1:]

def doc_to_text(doc):
    question_type = doc["question"]
    if question_type == "cause":
        question = "Kaj je razlog za to?"
    elif question_type == "effect":
        question = "Kaj se je zgodilo kot rezultat?"
    else:
        raise ValueError(f"Unknown question type: {question_type}")

    premise = doc["premise"].strip()
    return f"Predpostavka: {premise}\n{question}"

#def doc_to_choice(doc):
#    return [convert_choice(doc["choice1"]), convert_choice(doc["choice2"])]
def doc_to_choice(doc):
    return [doc["choice1"], doc["choice2"]]
# You don't need connector in this format anymore, but keeping for compatibility
doc_to_text_id = partial(
    doc_to_text,
    connector=None,
)
