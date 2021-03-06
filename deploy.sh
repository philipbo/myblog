#!/bin/bash

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

# mkdir public
# cd public
# git init
# git remote add upstream https://github.com/jdhao/jdhao.github.io.git

# Build the project.
hugo # if using a theme, replace with `hugo -t <YOURTHEME>`

# Go To Public folder
cd public

# Add changes to git.
git add .

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi

git commit -m "$msg"

# Push source and build repos.
git push upstream master

# Come Back up to the Project Root
cd ..
