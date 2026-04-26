#!/bin/bash
git add .
git status -s
echo ""
read -p "Commit message: " msg
git commit -m "$msg"

echo "Pushing to GitHub..."
git push origin main
echo "Pushing to Gitea..."
git push gitea main
echo "Done!"
