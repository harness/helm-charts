#!/bin/sh

# repo_name=harness-pl-infra
# owner=wings-software
# current_branch=test-pr-merge
# branch_name=test-pr-merge-test

repo_name=helm-charts
owner=harness
current_branch=test-pr-merge
branch_name=test-pr-merge-test

# copy from here in pipeline

# Create Changes PR
echo -e "------Creating PR-----\n"

# Get commit message for the changes
DEFAULT_MSG=$(git log --format=%B -n 1)

# Create PR with fixed prefix and commit message
PR_URL=$(gh pr create --repo "$owner/$repo_name" --base "$current_branch" --head "$branch_name" --title "chore: [PL-61236]: $DEFAULT_MSG" --assignee "@me" --fill)
if [ -z "$PR_URL" ]; then
    echo "Failed to create PR"
    exit 1
fi
echo "PR_URL: $PR_URL"

# Verify PR_URL is not empty
if [ -z "$PR_URL" ]; then
    echo "Failed to get PR URL. Aborting."
    exit 1
fi

# Check for merge conflicts
echo -e "------Checking for Merge Conflicts-----\n"
git fetch origin $current_branch
if ! CONFLICTS=$(git merge-tree $(git merge-base HEAD "origin/$current_branch") HEAD "origin/$current_branch" 2>&1); then 
    echo "Failed to check for merge conflicts: $CONFLICTS"
    exit 1
fi

if [ ! -z "$CONFLICTS" ]; then
    echo "Merge conflicts detected. Aborting."
    exit 1
fi

# Wait for checks (5 minutes maximum)
echo -e "------Waiting for Checks (max 5 minutes)-----\n"
attempts=10  # 10 attempts * 30 seconds = 5 minutes
for ((i=1; i<=attempts; i++)); do
    CHECK_STATUS=$(gh pr view $PR_URL --json statusCheckRollup -q ".statusCheckRollup[].state" | sort -u)
    
    if [[ "$CHECK_STATUS" == "SUCCESS" ]]; then
        echo "All checks passed!"
        break
    elif [[ "$CHECK_STATUS" == *"FAILURE"* ]]; then
        echo "Checks failed. Aborting."
        exit 1
    elif [[ $i == $attempts ]]; then
        echo "Timeout waiting for checks. Aborting."
        exit 1
    else
        echo "Checks still running (attempt $i/$attempts), checking again in 30 seconds..."
        sleep 30
    fi
done

# Attempt to merge
echo -e "------Squashing and Merging PR-----\n"
if gh pr merge $PR_URL --squash; then
    echo "PR merged successfully!"
else
    echo "Failed to merge PR. Aborting."
    exit 1
fi