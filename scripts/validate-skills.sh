#!/usr/bin/env bash
# Usage: ./scripts/validate-skills.sh [--verbose] [--help]
# Validates all SKILL.md and agent definition files.
# Returns exit code 0 if all pass, 1 if any fail.

set -euo pipefail
shopt -s nullglob

VERBOSE=false
ERRORS=0
PASSED=0

for arg in "$@"; do
  case "$arg" in
    --verbose) VERBOSE=true ;;
    --help|-h)
      echo "Usage: ./scripts/validate-skills.sh [--verbose]"
      echo "  Validates all SKILL.md and agent definition files."
      echo "  Returns exit code 0 if all pass, 1 if any fail."
      echo ""
      echo "Options:"
      echo "  --verbose  Show all checks, not just failures"
      echo "  --help     Show this help message"
      exit 0
      ;;
    *) echo "Unknown option: $arg"; exit 1 ;;
  esac
done

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

fail() {
  echo "FAIL: $1: $2" >&2
  echo "  FIX: $3" >&2
  ERRORS=$((ERRORS + 1))
}

pass() {
  PASSED=$((PASSED + 1))
  if $VERBOSE; then
    echo "PASS: $1: $2"
  fi
}

# Extract YAML frontmatter field value (single-line)
# Usage: get_frontmatter_field <file> <field>
get_frontmatter_field() {
  local file="$1" field="$2"
  # Handle quoted and unquoted values, strip leading/trailing whitespace and quotes
  sed -n '/^---$/,/^---$/p' "$file" \
    | grep -m1 "^${field}:" \
    | sed "s/^${field}:[[:space:]]*//" \
    | sed 's/^"\(.*\)"$/\1/' \
    | sed "s/^'\(.*\)'$/\1/"
}

# Extract full description (may be multi-line with |)
# Usage: get_description <file>
get_description() {
  local file="$1"
  local in_frontmatter=false
  local in_desc=false
  local desc=""

  while IFS= read -r line; do
    if [[ "$line" == "---" ]]; then
      if $in_frontmatter; then
        break
      fi
      in_frontmatter=true
      continue
    fi
    if ! $in_frontmatter; then
      continue
    fi

    if $in_desc; then
      # If line starts with a non-space char and contains ":", it's a new field
      if [[ "$line" =~ ^[a-zA-Z] ]]; then
        break
      fi
      # Continuation of multi-line description
      desc="$desc $(echo "$line" | sed 's/^[[:space:]]*//')"
    elif [[ "$line" =~ ^description: ]]; then
      local value
      value="$(echo "$line" | sed 's/^description:[[:space:]]*//' | sed 's/^"\(.*\)"$/\1/' | sed "s/^'\(.*\)'$/\1/")"
      if [[ "$value" == "|" || "$value" == ">" || "$value" == ">-" || "$value" == "|-" ]]; then
        in_desc=true
      elif [[ -n "$value" ]]; then
        desc="$value"
        in_desc=true
      fi
    fi
  done < "$file"

  echo "$desc"
}

# Check if frontmatter has a field (even if empty or multi-line)
has_frontmatter_field() {
  local file="$1" field="$2"
  sed -n '/^---$/,/^---$/p' "$file" | grep -q "^${field}:" 2>/dev/null
}

# ============================================================
# Validate SKILL.md files
# ============================================================

for skill_file in "$ROOT"/plugins/*/skills/*/SKILL.md; do
  rel_path="${skill_file#"$ROOT"/}"
  skill_dir="$(basename "$(dirname "$skill_file")")"

  # 1. Line count under 500
  lines=$(wc -l < "$skill_file" | tr -d ' ')
  if [ "$lines" -gt 500 ]; then
    fail "$rel_path" "line count $lines exceeds 500" "Extract verbose sections to references/ directory"
  else
    pass "$rel_path" "line count $lines OK"
  fi

  # 2. Name matches directory
  name_field=$(get_frontmatter_field "$skill_file" "name")
  if [ -z "$name_field" ]; then
    fail "$rel_path" "missing 'name' field in frontmatter" "Add 'name: skill-name' to YAML frontmatter"
  elif [ "$name_field" != "$skill_dir" ]; then
    fail "$rel_path" "name '$name_field' does not match directory '$skill_dir'" "Rename to 'name: $skill_dir' or move file to matching directory"
  else
    pass "$rel_path" "name matches directory"
  fi

  # 3. Description length under 1024
  desc=$(get_description "$skill_file")
  if [ -z "$desc" ]; then
    fail "$rel_path" "missing or empty 'description' field" "Add 'description: >-' with 1-2 sentence description"
  else
    desc_len=${#desc}
    if [ "$desc_len" -gt 1024 ]; then
      fail "$rel_path" "description length $desc_len exceeds 1024" "Shorten description to under 1024 chars"
    else
      pass "$rel_path" "description length $desc_len OK"
    fi
  fi

  # 4. Required fields: name, description, model
  for field in name description model; do
    if ! has_frontmatter_field "$skill_file" "$field"; then
      fail "$rel_path" "missing required field '$field'" "Add '$field:' to YAML frontmatter"
    else
      pass "$rel_path" "has required field '$field'"
    fi
  done
  # allowed-tools is present on most skills; warn if missing since brief/think omit it intentionally
  if ! has_frontmatter_field "$skill_file" "allowed-tools"; then
    if $VERBOSE; then
      echo "WARN: $rel_path: missing 'allowed-tools' field"
    fi
  else
    pass "$rel_path" "has required field 'allowed-tools'"
  fi

  # 5. No dead references — check references/*.md mentioned in SKILL.md
  ref_dir="$(dirname "$skill_file")/references"
  while IFS= read -r ref_mention; do
    ref_file="$(dirname "$skill_file")/$ref_mention"
    if [ ! -f "$ref_file" ]; then
      fail "$rel_path" "dead reference: '$ref_mention' not found" "Create missing file or remove reference from SKILL.md"
    else
      pass "$rel_path" "reference '$ref_mention' exists"
    fi
  done < <(grep -v '@references/' "$skill_file" 2>/dev/null | grep -oE 'references/[a-zA-Z0-9_-]+\.md' || true)

  # 6. Description starts with verb (heuristic)
  first_word=$(echo "$desc" | awk '{print $1}')
  if echo "$first_word" | grep -qE '^[A-Z][a-z]+s$'; then
    pass "$rel_path" "description starts with verb ('$first_word')"
  elif echo "$first_word" | grep -qEi '^(the|a|an|this)$'; then
    fail "$rel_path" "description should start with a verb, not '$first_word'" "Start with an action verb: 'Launches...', 'Conducts...', 'Analyzes...'"
  else
    pass "$rel_path" "description first word '$first_word' (manual check)"
  fi

  # 7. Has negative triggers ("Don't use for...")
  if grep -qi "don't use\|do not use\|not for\|don't use for" "$skill_file"; then
    pass "$rel_path" "has negative triggers"
  else
    fail "$rel_path" "missing negative triggers in description or body" "Add 'Don't use for...' to description to prevent misuse"
  fi

  # 8. Has error handling section
  if grep -qi "## Error Handling\|## Stuck Protocol" "$skill_file"; then
    pass "$rel_path" "has error handling section"
  else
    fail "$rel_path" "missing error handling section" "Add '## Error Handling' table with situation/action pairs"
  fi
done

# ============================================================
# Validate agent definition files
# ============================================================

for agent_file in "$ROOT"/plugins/*/agents/*.md; do
  rel_path="${agent_file#"$ROOT"/}"

  # 1. Required fields: name, description, model
  for field in name description model; do
    if ! has_frontmatter_field "$agent_file" "$field"; then
      fail "$rel_path" "missing required field '$field'" "Add '$field:' to YAML frontmatter"
    else
      pass "$rel_path" "has required field '$field'"
    fi
  done

  # 2. Must have either 'tools' or 'disallowedTools', not both, not neither
  has_tools=false
  has_disallowed=false
  if has_frontmatter_field "$agent_file" "tools"; then
    has_tools=true
  fi
  if has_frontmatter_field "$agent_file" "disallowedTools"; then
    has_disallowed=true
  fi

  if $has_tools && $has_disallowed; then
    fail "$rel_path" "has both 'tools' and 'disallowedTools' — use only one" "Remove one: use 'tools' for allowlist or 'disallowedTools' for blocklist"
  elif ! $has_tools && ! $has_disallowed; then
    fail "$rel_path" "missing both 'tools' and 'disallowedTools' — must have one" "Add 'tools:' (allowlist) or 'disallowedTools:' (blocklist)"
  else
    pass "$rel_path" "tool specification OK"
  fi

  # 3. Name format: lowercase-kebab-case
  agent_name=$(get_frontmatter_field "$agent_file" "name")
  if [ -n "$agent_name" ]; then
    if ! echo "$agent_name" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'; then
      fail "$rel_path" "name '$agent_name' is not lowercase-kebab-case" "Rename to lowercase-kebab-case: $(echo "$agent_name" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')"
    else
      pass "$rel_path" "name format OK"
    fi
  fi
done

# ============================================================
# Summary
# ============================================================

echo ""
echo "=============================="
if [ "$ERRORS" -gt 0 ]; then
  echo "FAILED: $ERRORS error(s), $PASSED passed"
  echo "=============================="
  exit 1
else
  echo "ALL PASSED: $PASSED check(s)"
  echo "=============================="
  exit 0
fi
