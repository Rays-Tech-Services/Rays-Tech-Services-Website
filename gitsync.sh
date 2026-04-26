#!/bin/bash
git add .

if [ -n "$1" ]; then
    msg="$1"
else
    git status -s
    echo ""
    read -p "Commit message: " msg
fi

git commit -m "$msg"

echo "Pushing to GitHub..."
git push origin main
echo "Pushing to Gitea..."
git push gitea main
echo "Done!"
