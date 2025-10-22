letters = list(map(chr, range(ord('A'), ord('Z')+1)))

def doc_to_text(doc):
    question = doc["question"]
    ctx = doc["context"]
    
    # drop any examples that contain context
    if len(ctx.split()) > 5:
        print(f"{ctx.split()}, {len(ctx.split())}")
        print(f"Dropping {doc}")
        return
    
    answers = ""
    for n, ans in enumerate(doc["options"]):
        answers += f"{letters[n]}) {ans}\n"

    answers += "\nAtbilde:"

    return f"{question}\n{ctx}\n{answers}"


def doc_to_choice(doc):
    return [f"{letters[n]}) {ans}" for n, ans in enumerate(doc["options"])]


def doc_to_target(doc):
    return f"{letters[doc['correct_answer_index']]}) {doc['correct_answer_text']}"
