# Gold Standard: Skill Definition

## Pattern
YAML frontmatter:
- name: lowercase-kebab-case
- description: third-person voice ("Launches...", "Conducts..."), include negative triggers ("Don't use for..."), under 1024 chars
- allowed-tools: list of tools Lead can use
- argument-hint: usage pattern
- model: opus

Body structure:
1. `#` Title with pipeline description
2. `## Philosophy` section
3. `## Arguments` section
4. `## Phases` (numbered, with steps)
5. `## Stuck Protocol` or `## Error Handling` table
6. `## Key Rules` list

## Key rules
- Skills define orchestration, not implementation
- Skill file is the Lead's brain -- it orchestrates, never codes
- SKILL.md MUST be under 500 lines; extract verbose sections into colocated `references/` directory
- JiT loading: reference files use explicit "when X happens, read Y" triggers, not loaded at init
- Use tables for event contracts and protocol matrices
- Phases use numbered steps with concrete agent spawn patterns
- Every skill MUST have an error handling / stuck protocol table

## Reference
- `plugins/team/skills/build/SKILL.md` (canonical multi-phase skill)
- `plugins/team/skills/build/references/` (canonical reference extraction pattern)
