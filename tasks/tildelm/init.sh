#!/bin/bash

# List of subtasks
tasks=("arc_tlm" "hellaswag_tlm" "mmlu_tlm")

# List of languages
languages=("bg" "cnr" "cr" "cz" "et" "fi" "lt" "lv" "md" "pl" "sl")

# List of splits per task
declare -A splits
splits["arc_tlm"]="test validation"
splits["hellaswag_tlm"]="validation"
splits["mmlu_tlm"]="test validation"

# Define the 'clean' variable (adjust as needed)
clean="clean"

# Flag to track if any task-level folder was created
task_folder_created=false

# Function to create the appropriate YAML content
create_yaml() {
    local task=$1
    local lang=$2
    local split_list=$3

    # Base YAML structure
    yaml_content="dataset_path: json
dataset_name: null
dataset_kwargs:
  data_files:
"

    # Add all splits to the YAML content
    for split in $split_list; do
        yaml_content+="    ${split}: lm_eval/tasks/tildelm/${task}/${lang}/${task}-${lang}-${split}.jsonl
"
    done

    # Add all splits to the YAML content
    for split in $split_list; do
        yaml_content+="${split}_split: ${split}
"
    done

    # Add task-specific fields
    yaml_content+="task: ${task}_${lang}
"

    if [ "$task" == "hellaswag_tlm" ]; then
        yaml_content+="output_type: multiple_choice
process_docs: !function utils.process_docs
doc_to_text: \"query\"
doc_to_target: \"{{label.lstrip()}}\"
doc_to_choice: \"choices\"
metric_list:
  - metric: acc
    aggregation: mean
    higher_is_better: true
  - metric: acc_norm
    aggregation: mean
    higher_is_better: true
metadata:
  version: 1.0
"
    elif [ "$task" == "mmlu_tlm" ]; then
        yaml_content+="fewshot_config:
  sampler: first_n
output_type: multiple_choice
doc_to_text: \"{{instruction.strip()}}\\nA. {{option_a}}\\nB. {{option_b}}\\nC. {{option_c}}\\nD. {{option_d}}\\nAnswer:\"
doc_to_choice: [\"A\", \"B\", \"C\", \"D\"]
doc_to_target: answer
metric_list:
  - metric: acc
    aggregation: mean
    higher_is_better: true
metadata:
  version: 1.0
"
    elif [ "$task" == "arc_tlm" ]; then
        yaml_content+="output_type: multiple_choice
process_docs: !function utils.process_docs
doc_to_text: \"query\"
doc_to_target: \"gold\"
doc_to_choice: \"choices\"
metric_list:
  - metric: acc
    aggregation: mean
    higher_is_better: true
  - metric: acc_norm
    aggregation: mean
    higher_is_better: true
metadata:
  version: 1.0
"
    fi

    echo "$yaml_content"
}

# Check for task-level folders
for task in "${tasks[@]}"; do
    if [ ! -d "$task" ]; then
        # Create the task-level folder
        mkdir "$task"
        echo "Created task-level folder: $task"
        task_folder_created=true
    else
        echo "Task-level folder already exists: $task"
    fi
done

# Step 1: Copy task-specific utils.py files
for task in "${tasks[@]}"; do
    utils_source_file="${task}_utils.py"
    utils_destination_file="${task}/utils.py"

    if [ -f "$utils_source_file" ]; then
        # Create the task folder if it doesn't exist
        mkdir -p "$task"
        # Copy the utils.py file
        cp "$utils_source_file" "$utils_destination_file"
        echo "Copied: $utils_source_file -> $utils_destination_file"
    else
        echo "Utils file not found for task: $task. Skipping."
    fi
done

# Exit if all task-level folders already exist
if ! $task_folder_created; then
    echo "All task-level folders already exist. Exiting script."
    exit 0
fi

# Proceed to create language folders and copy files
for task in "${tasks[@]}"; do
    # Get the appropriate splits for the task
    task_splits=${splits[$task]}

    # Loop through languages
    for lang in "${languages[@]}"; do
        # Create the task-language folder path
        task_lang_folder="${task}/${lang}"

        if [ ! -d "$task_lang_folder" ]; then
            mkdir -p "$task_lang_folder"
            echo "Created folder: $task_lang_folder"
        fi

        # Create a symlink to the utils.py file if it exists
        utils_source_file="${task}/utils.py"
        symlink_target="${task_lang_folder}/utils.py"

        if [ -f "$utils_source_file" ]; then
            ln -sf "../../utils.py" "$symlink_target"
            echo "Created symlink: $symlink_target -> $utils_source_file"
        else
            echo "No utils.py file found for task: $task. Skipping symlink creation."
        fi

        # Create the YAML file at the task-language level
        yaml_file="${task_lang_folder}/${task}_${lang}.yaml"
        yaml_content=$(create_yaml "$task" "$lang" "$task_splits")
        echo "$yaml_content" > "$yaml_file"
        echo "Created YAML file: $yaml_file"

        # Loop through splits
        for split in $task_splits; do
            # Source file path
            source_file="../../../../data/${task}/${clean}/${split}/${lang}/${lang}-output-clean.jsonl"

            # Destination file path
            destination_file="${task_lang_folder}/${task}-${lang}-${split}.jsonl"

            # Check if the source file exists before copying
            if [ -f "$source_file" ]; then
                # Copy and rename the file
                cp "$source_file" "$destination_file"
                echo "Copied and renamed: $source_file -> $destination_file"
            else
                echo "Source file not found: $source_file. Skipping."
            fi
        done
    done

    # Copy the ${task}_utils.py to ${task}/utils.py if it exists
    utils_source_file="${task}_utils.py"
    utils_destination_file="${task}/utils.py"

    if [ -f "$utils_source_file" ]; then
        cp "$utils_source_file" "$utils_destination_file"
        echo "Copied: $utils_source_file -> $utils_destination_file"
    else
        echo "Utils file not found for task: $task. Skipping."
    fi
done

echo "All required folders, files, and YAML configurations have been processed."
