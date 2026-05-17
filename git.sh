#!/bin/bash

echo "=== Starting project synchronization ==="
git add .

echo "Enter commit message:"
read -r commit_message

if [ -z "$commit_message" ]; then
    echo "Error: Commit message cannot be empty. Operation aborted."
    exit 1
fi

git commit -m "$commit_message"

echo "Fetching latest changes from GitHub..."
if git pull origin main --rebase; then
    echo "Synchronization successful."
else
    echo "Error: Conflict detected during synchronization. Resolve conflicts and try again."
    exit 1
fi

echo "Pushing code to Merix-Industries organization..."
git push origin main

echo "=== Push completed successfully ==="
