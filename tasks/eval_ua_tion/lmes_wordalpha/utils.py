def doc_to_text(doc):
    return f'{doc['system_prompts'][0]}\n{doc['question']}\n\n'


def doc_to_choice(doc):
    return [doc['additionalMetadata_option_0'], doc['additionalMetadata_option_1']]