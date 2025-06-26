def doc_to_text(doc):
    function_code = doc["instruction"].strip()
    return function_code.format(function=doc["inputs"]["function"])

def doc_to_target(doc):
    # Join the output list into newline-separated answers, or JSON-style list
    return "\n".join(doc["outputs"])