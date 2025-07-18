def doc_to_text(doc):
    OUTPUT = []
    for i in range(len(doc["question"]["choices"]["text"])):
        label = doc["question"]["choices"]["label"][i]
        text = doc["question"]["choices"]["text"][i]
        OUTPUT.append(f"{label}: {text}")
    return f"{doc['question']['stem']}\n\n" + "\n".join(OUTPUT)


def doc_to_choice(doc):
    #OUTPUT = []
    #for i in range(len(doc["question"]["choices"]["text"])):
        #label = doc["question"]["choices"]["label"][i]
        #text = doc["question"]["choices"]["text"][i]
        #OUTPUT.append(f"{label}: {text}\n{para}\n\n")
    return ["A", "B", "C", "D"]


def doc_to_target(doc):
    return doc["answerKey"]

