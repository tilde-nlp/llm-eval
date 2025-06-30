def doc_to_text(doc):
    OUTPUT = []
    for i in range(len(doc["question"]["choices"]["text"])):
        label = doc["question"]["choices"]["label"][i]
        text = doc["question"]["choices"]["text"][i]
        para = doc["question"]["choices"]["para"][i]
        OUTPUT.append(f"{label}: {text}\n{para}\n")

    # Join all choices and prepend the stem
    return f"{doc['question']['stem']}\n\n" + "\n".join(OUTPUT)


def doc_to_choice(doc):
    OUTPUT = []
    for i in range(len(doc["question"]["choices"]["text"])):
        label = doc["question"]["choices"]["label"][i]
        text = doc["question"]["choices"]["text"][i]
        para = doc["question"]["choices"]["para"][i]
        OUTPUT.append(f"{label}: {text}\n{para}\n\n")
    return OUTPUT


def doc_to_target(doc):
    return doc["answerKey"]

