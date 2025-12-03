#!/usr/bin/env bash
set -euo pipefail

# Publish image helper script (bash)
# - Stages changes, commits, pushes, and triggers GitHub Actions workflow_dispatch
# - Requires environment variable: GITHUB_TOKEN

if [ -z "${GITHUB_TOKEN-}" ]; then
  echo "ERROR: GITHUB_TOKEN environment variable is not set. Export it before running this script." >&2
  exit 1
fi

REPO_OWNER="jandromani"
REPO_NAME="TESTCOPILOT"
WORKFLOW_FILE="build-and-push-image.yml"
BRANCH="master"

echo "Staging changes..."
git add -A

if [ -z "$(git status --porcelain)" ]; then
  echo "No changes to commit. Proceeding to trigger workflow..."
else
  echo "Committing changes..."
  git commit -m "chore(ci): add publish scripts and remote run docs" || { echo "git commit failed"; exit 1; }
fi

echo "Pushing to origin/$BRANCH..."
git push origin "$BRANCH" || { echo "git push failed. Ensure you have push access and credentials configured (SSH key or PAT)."; exit 1; }

echo "Triggering GitHub Actions workflow_dispatch for $WORKFLOW_FILE on $BRANCH..."

URL="https://api.github.com/repos/$REPO_OWNER/$REPO_NAME/actions/workflows/$WORKFLOW_FILE/dispatches"
BODY="{ \"ref\": \"$BRANCH\" }"

curl -s -X POST -H "Authorization: token $GITHUB_TOKEN" -H "Accept: application/vnd.github.v3+json" "$URL" -d "$BODY"
echo "\nWorkflow dispatch requested. Check Actions tab in the repository."
