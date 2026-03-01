# Convention Check: Skill Validation

Rules enforced by `scripts/validate-skills.sh`:

## Frontmatter schema
- `name`: required, lowercase-kebab-case
- `description`: required, under 1024 characters
- `model`: required
- `allowed-tools`: optional (WARN if missing), non-empty list when present

## Description rules
- Third-person voice ("Launches...", "Conducts...", not "You launch...")
- Include negative triggers ("Don't use for...")
- Under 1024 characters total

## File rules
- SKILL.md body under 500 lines (frontmatter excluded from count)
- Verbose sections extracted into colocated `references/` directory
- JiT pointers use "See references/X.md for..." format

## Error handling
- Every skill MUST have an error handling or stuck protocol table
- Table covers: agent stuck, review loops, tool failures, build failures

## Reference paths
- `@references/` resolves from plugin root, not skill directory
- Skill-local references use `references/` (relative to skill dir)
- All referenced files must exist (no dead links)
