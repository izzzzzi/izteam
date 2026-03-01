# Validation Playbook

Step-by-step validation for SKILL.md and agent definition files. Run after any changes to ensure compliance with project conventions.

## Step 1: Automated Validation

```bash
./scripts/validate-skills.sh --verbose
```

All checks must pass. Fix any failures using the `FIX:` suggestions in the output.

## Step 2: Language Compliance

Verify no Russian (Cyrillic) characters appear in operational files. Russian is only acceptable in `README.ru.md` files.

```bash
grep -rn '[а-яА-ЯёЁ]' plugins/ --include="*.md" | grep -v 'README.ru.md' | grep -v 'README.md:.*Русский'
```

**Expected:** Zero matches.

## Step 3: Voice Compliance

Check that SKILL.md files use third-person voice (not second-person "You/Your" addressing the Lead).

```bash
for f in plugins/*/skills/*/SKILL.md; do
  matches=$(grep -cn '\bYou \|\bYour ' "$f" 2>/dev/null || echo "0")
  if [ "$matches" -gt 0 ]; then
    echo "WARN: $f has $matches second-person references"
    grep -n '\bYou \|\bYour ' "$f"
  fi
done
```

**Expected:** Zero warnings. Exception: "You" inside code blocks addressed to other agents (e.g., spawn prompts) is acceptable.

## Step 4: Structural Compliance

Check that all SKILL.md files stay under 500 lines and all references resolve:

```bash
for f in plugins/*/skills/*/SKILL.md; do
  lines=$(wc -l < "$f" | tr -d ' ')
  if [ "$lines" -gt 500 ]; then
    echo "OVER LIMIT: $f ($lines lines)"
  else
    echo "OK: $f ($lines lines)"
  fi
done
```

**Expected:** All files under 500 lines.

## Scoring Rubric

| Category | Weight | Pass Criteria |
|----------|--------|---------------|
| Automated checks | 40% | All `validate-skills.sh` checks pass |
| Language compliance | 20% | Zero Cyrillic in operational files |
| Voice compliance | 15% | Zero second-person in SKILL.md body text |
| Structural compliance | 15% | All SKILL.md under 500 lines |
| Reference integrity | 10% | All `references/*.md` mentions resolve to existing files |

**Overall:** 100% = all categories pass. Below 80% = requires immediate remediation.

## LLM Validation Prompts

For deeper validation, use these prompts with an LLM:

### Prompt 1: Convention Compliance
```
Read the file [path] and check:
1. Does the YAML frontmatter have: name, description, model?
2. Does the description start with a verb and include negative triggers?
3. Is there an Error Handling or Stuck Protocol section?
4. Are all @references/ paths valid files?
Report violations with line numbers.
```

### Prompt 2: Terminology Consistency
```
Read all files in plugins/ and check against .conventions/glossary.md:
1. Are any forbidden synonyms used?
2. Is capitalization consistent (gold standard, Lead, SIMPLE/MEDIUM/COMPLEX)?
3. Are there phantom role references (roles mentioned but not defined)?
Report each violation with file:line.
```

### Prompt 3: Progressive Disclosure
```
Read [SKILL.md path] and check:
1. Is any section longer than 30 lines that could be extracted to references/?
2. Are reference loads JiT (triggered by reaching a phase) not at init?
3. Does the file stay focused on orchestration, not implementation details?
Report sections that should be extracted.
```

### Prompt 4: Agent Contract Compliance
```
Read [agent.md path] and check against .conventions/gold-standards/agent-definition.md:
1. Does it have a <role> block?
2. Does it have <output_rules>?
3. Are examples in description matching actual protocol?
4. Is the tool specification correct (tools OR disallowedTools, not both)?
Report violations.
```
