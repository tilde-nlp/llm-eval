#!/bin/bash

# Set the target directory
TARGET_DIR="../lm-evaluation-harness/lm_eval/tasks"

# Loop through all items in current directory
for dir in */; do
  # Only copy if it's a directory
  if [ -d "$dir" ]; then
    echo "Copying $dir to $TARGET_DIR"
    cp -r "$dir" "$TARGET_DIR"
  fi
done

echo "All directories copied to $TARGET_DIR."
