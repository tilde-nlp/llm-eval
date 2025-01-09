from transformers import LlamaTokenizer

# Path to your tokenizer.model file
tokenizer_model_path = "tokenizer.model"

# Load the tokenizer
tokenizer = LlamaTokenizer.from_pretrained(tokenizer_model_path)

# Save the tokenizer, including the tokenizer.json and configuration
tokenizer.save_pretrained("./")

print("Generated tokenizer.json and tokenizer_config.json files in the current directory.")


# ----------------- OR COULD ALSO TRY THIS --------------

# from transformers import LlamaTokenizer
#
# # Path to your tokenizer.model file
# tokenizer_model_path = "tokenizer.model"
#
# # Load the tokenizer
# tokenizer = LlamaTokenizer.from_pretrained(tokenizer_model_path)
#
# # Manually serialize the vocabulary and tokenization logic into JSON format
# tokenizer_json_path = "./tokenizer.json"
# with open(tokenizer_json_path, "w", encoding="utf-8") as f:
#     json_data = tokenizer.save_vocabulary(".")
#     f.write(json_data)
#
# print("Manually generated tokenizer.json in the current directory.")
