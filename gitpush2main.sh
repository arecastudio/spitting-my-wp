#!/bin/bash

# Prompt for commit message if not provided as an argument
if [ -z "$1" ]; then
  read -p "Enter commit message: " commit_message
else
  commit_message="$1"
fi

# Stage all changes
git add .

# Commit changes
git commit -m "$commit_message"

# Get the current branch name
branch=$(git symbolic-ref --short HEAD)

# Push to the remote repository (origin by default) and current branch
git push origin "$branch"
