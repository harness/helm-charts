#!/bin/bash

set -e

# Repository mappings: from -> to
REPO_MAPPINGS="harness:harnesssecure plugins:harnesssecure"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Cross-platform sed -i
if sed --version 2>/dev/null | grep -q GNU; then
  _sed_i() { sed -i "$@"; }
else
  _sed_i() { sed -i '' "$@"; }
fi

# Build one combined sed expression for all mappings
SED_EXPR=""
for mapping in $REPO_MAPPINGS; do
  from="${mapping%%:*}"
  to="${mapping##*:}"
  [ "$from" = "$to" ] && continue
  SED_EXPR="${SED_EXPR}s|docker\.io/${from}/|docker.io/${to}/|g;"
  SED_EXPR="${SED_EXPR}s|: ${from}/|: ${to}/|g;"
  SED_EXPR="${SED_EXPR}s|: \"${from}/|: \"${to}/|g;"
  SED_EXPR="${SED_EXPR}s|: '${from}/|: '${to}/|g;"
  SED_EXPR="${SED_EXPR}s| ${from}/| ${to}/|g;"
  SED_EXPR="${SED_EXPR}s|^${from}/|${to}/|g;"
done

echo -e "${GREEN}=== Image Repository Migration ===${NC}"
for mapping in $REPO_MAPPINGS; do
  echo "  ${mapping%%:*}/ -> ${mapping##*:}/"
done
echo ""

# Pre-filter with grep to skip the ~1000 files that have no matches at all
CANDIDATE_FILES=$(find "$SCRIPT_DIR" -type f \( -name "*.yaml" -o -name "*.yml" -o -name "images.txt" \) \
  -exec grep -lE 'harness/|plugins/' {} + 2>/dev/null || true)

if [ -z "$CANDIDATE_FILES" ]; then
  echo -e "${YELLOW}No files need migration.${NC}"
  exit 0
fi

MODIFIED_COUNT=0

while IFS= read -r file; do
  BEFORE=$(cksum < "$file")
  _sed_i "$SED_EXPR" "$file"
  AFTER=$(cksum < "$file")
  if [ "$BEFORE" != "$AFTER" ]; then
    MODIFIED_COUNT=$((MODIFIED_COUNT + 1))
    echo -e "${GREEN}✓${NC} ${file#$SCRIPT_DIR/}"
  fi
done <<< "$CANDIDATE_FILES"

echo ""
if [ "$MODIFIED_COUNT" -eq 0 ]; then
  echo -e "${YELLOW}All files already migrated. Nothing to do.${NC}"
else
  echo -e "${GREEN}=== Done: migrated $MODIFIED_COUNT files ===${NC}"
fi
