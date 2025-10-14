#!/usr/bin/env sh

set -e -x # -e: errexit -x: xtrace

# Clone the repository and checkout the branch
git clone "$CI_REPOSITORY_URL" repo && cd repo && git checkout $CI_COMMIT_REF_NAME

# Echo commit ref name
echo "Commit ref name $CI_COMMIT_REF_NAME"

# Echo CI merge request target branch name
echo "Merge request target branch name $CI_MERGE_REQUEST_TARGET_BRANCH_NAME"

# Get the list of directories that were modified
if [ ! -z "$CI_MERGE_REQUEST_TARGET_BRANCH_NAME" ]; then
  DIFF_TARGET="$CI_MERGE_REQUEST_TARGET_BRANCH_NAME"
  echo "Diff target: $DIFF_TARGET"
else
  DIFF_TARGET="HEAD^"
  echo "Diff target: $DIFF_TARGET"
fi
git diff --name-status --diff-filter=AMR $DIFF_TARGET | awk '{print $2}' | grep '/' | cut -d/ -f1 | sort -u > $CI_PROJECT_DIR/dirs.txt.temp

# List of files that were modified
git diff --name-status --diff-filter=AMR $DIFF_TARGET

# Create dirs.txt file which will contain the list of directories that need to be processed
touch $CI_PROJECT_DIR/dirs.txt

# Print the content of dirs.txt.temp for debugging
cat $CI_PROJECT_DIR/dirs.txt.temp

# Check if README.md is present in all directories that were modified/added
if [ "$CHECK_README" == "TRUE" ]; then
  while IFS= read -r dir; do
    if [ ! -f "$dir/README.md" ]; then
      echo "Failed: README.md not found in $dir"
      exit 1
    fi
  done < $CI_PROJECT_DIR/dirs.txt.temp
fi

# Check if only README is updated or added and skip those directories
while IFS= read -r dir; do
    echo "Checking directory: $dir"
    git_diff_result=$(git diff --name-status $DIFF_TARGET -- $dir)
    echo "Diff for $dir: $git_diff_result"
    if [[ "$git_diff_result" =~ ^M[[:space:]]$dir/README\.md$ || "$git_diff_result" =~ ^A[[:space:]]$dir/README\.md$ ]]; then
        echo "Skipping $dir as only README.md was modified/added"
    else
        echo "Adding $dir to dirs.txt for further processing"
        echo "$dir" >> $CI_PROJECT_DIR/dirs.txt
    fi
done < $CI_PROJECT_DIR/dirs.txt.temp

# Remove temp file
rm $CI_PROJECT_DIR/dirs.txt.temp

# Print the list of directories that need to be processed
cat $CI_PROJECT_DIR/dirs.txt
