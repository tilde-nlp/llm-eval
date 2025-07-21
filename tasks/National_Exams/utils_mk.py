def doc_to_text(doc):
    OUTPUT = []
    for i in range(len(doc["question"]["choices"]["text"])):
        label = doc["question"]["choices"]["label"][i]
        text = doc["question"]["choices"]["text"][i]
        OUTPUT.append(f"{label}: {text}")
    return f"{doc['question']['stem']}\n" + "\n".join(OUTPUT)+ "\n\nОдговорот: "


def doc_to_choice(doc):
    return ["A", "B", "C", "D"]


def doc_to_target(doc):
    r = {'A':0, 'B':1, 'C':2, 'D':3}
    return r[doc["answerKey"]]

