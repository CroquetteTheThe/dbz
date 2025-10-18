#!/bin/bash


# Move to the Git repository root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

# Check for flags
NO_PULL=false
LOCAL_MODE=false
DRY_MODE=false
FILES=()

for arg in "$@"; do
  case "$arg" in
    --no-pull) NO_PULL=true ;;
    --local) LOCAL_MODE=true ;;
    --dry) DRY_MODE=true ;;
    *) FILES+=("$arg") ;;
  esac
done

# Check if at least one file is provided
if [ "${#FILES[@]}" -eq 0 ]; then
  echo "Usage: ./upload.sh [--no-pull] [--local] <file1> [file2 ...]"
  exit 1
fi

# Get current branch name
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# Ensure we are on main branch
if [ "$CURRENT_BRANCH" != "main" ]; then
  echo "Error: You must be on the main branch to upload files."
  exit 1
fi

# Pull latest changes unless --no-pull
if [ "$NO_PULL" = false ]; then
  git pull origin main
else
  echo "Skipping git pull due to --no-pull"
fi

mkdir -p public/uploads  # Ensure 'uploads' folder exists

for FILE in "${FILES[@]}"; do
  DEST="public/uploads/$(basename "$FILE")"

  if git ls-files --error-unmatch "$DEST" >/dev/null 2>&1; then
    echo "Syncing existing file: $DEST"
  else
    echo "Adding new file: $DEST"
  fi

  if [ "$LOCAL_MODE" = false ]; then
    cp "$FILE" "$DEST"
    git add "$DEST"
  else
    echo "Skipping copy (local mode): $FILE"
    git add "$FILE"
  fi

done

git status

# Commit only if there are changes
if git diff --cached --quiet; then
  echo "No changes detected, skipping commit."
  exit 0
fi

if [ "$DRY_MODE" = false ]; then
  git commit -m "Updated files: $(printf '%s ' "${FILES[@]}")"
  git push origin main
fi

echo "Files successfully synced to main."
