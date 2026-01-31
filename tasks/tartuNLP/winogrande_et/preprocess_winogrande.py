def doc_to_text(doc):
    # Extract the correct answer from the qID
    answer_index = int(doc["qID"].split("-")[-1])-1   # 0 for option1, 1 for option2
    return answer_index  # returns 0 or 1

def doc_to_target(doc):
    idx = doc["sentence"].index("_") + 1
    return doc["sentence"][idx:].strip()


def doc_to_choice(doc):
    idx = doc["sentence"].index("_")
    options = [doc["option1"], doc["option2"]]
    return [doc["sentence"][:idx] + opt for opt in options]