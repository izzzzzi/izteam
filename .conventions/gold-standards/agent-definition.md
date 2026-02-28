# Gold Standard: Agent Definition

## Pattern
YAML frontmatter:
- name: lowercase-kebab-case
- description: with `<example>` blocks (positive + negative)
- model: opus (default for all agents)
- color: unique per agent
- tools: list of allowed tools (allowlist — blocks all unlisted tools including MCP)
- disallowedTools: list of blocked tools (blocklist — inherits all tools from main conversation except listed ones)

Body structure:
1. `<role>` block -- 3-5 line identity statement
2. `##` Sections -- responsibilities, methodology, protocols
3. Communication protocol table (if agent sends messages)
4. `<output_rules>` block -- 5-10 concrete rules

## Key rules
- Never start with "I" in role block
- Examples in description: 2-3 positive, 1 negative
- tools is an allowlist — agent cannot use unlisted tools. Use for agents that need strict control.
- disallowedTools is a blocklist — agent inherits everything except listed. Use for agents that need MCP access.
- Pick ONE: tools OR disallowedTools, never both
- Read-only agents: block Edit, Write, Bash, NotebookEdit, ExitPlanMode, EnterPlanMode, EnterWorktree
- Team member agents: do NOT block SendMessage, Task*, Team* tools
- output_rules close the file

## Reference
- `plugins/agent-teams/agents/supervisor.md` (canonical permanent agent)
- `plugins/agent-teams/agents/coder.md` (canonical temporary agent with comms protocol)
- `plugins/think-through/agents/expert.md` (canonical read-only agent with disallowedTools for MCP access)
