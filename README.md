# izteam — Claude Code Plugins

A collection of plugins for [Claude Code](https://claude.ai/code).

## Installation

Add this marketplace to Claude Code:

```bash
/plugin marketplace add izzzzzi/izteam
```

Then install any plugin:

```bash
/plugin install <plugin-name>@izteam
```

**Important:** Restart Claude Code after installing plugins to load them.

## Available Plugins

### think-through

Deep structured thinking with parallel expert analysis before implementation.

```bash
/plugin install think-through@izteam
```

**Usage:**
```
/deep-thinking <task or idea>
```

Breaks down your task into aspects, launches expert agents in parallel, and produces a comprehensive design document with decisions, trade-offs, and implementation plan.

[Read more →](./plugins/think-through/README.md)

---

### vibe-audit

Interactive feature audit for vibe-coded projects. Finds dead code, unused features, and experiments through conversation.

```bash
/plugin install vibe-audit@izteam
```

**Usage:**
```
/vibe-audit              # Full codebase scan
/vibe-audit features     # src/features/ deep audit
/vibe-audit server       # src/server/ routers & services
/vibe-audit ui           # src/design-system/ components
/vibe-audit stores       # src/stores/ Zustand state
```

[Read more →](./plugins/vibe-audit/README.md)

---

### agent-teams

Launch a team of AI agents to implement features with built-in code review gates.

> **Requires:** Enable `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` in settings.json or environment. [See setup →](./plugins/agent-teams/README.md#prerequisites)

```bash
/plugin install agent-teams@izteam
```

**Usage:**
```
/team-feature "Add user settings page"
/team-feature docs/plan.md --coders=2
/conventions
```

Spawns a full team — researchers explore your codebase, coders implement with gold standard examples, 3 specialized reviewers (security, logic, quality) check every change, and a Tech Lead validates architecture.

[Read more →](./plugins/agent-teams/README.md)

---

### expert-arena

Expert debate arena — real experts argue organically and converge on optimal solutions for any domain.

> **Requires:** Enable `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` in settings.json or environment.

```bash
/plugin install expert-arena@izteam
```

**Usage:**
```
/expert-arena "Should we use microservices or monolith?"
/expert-arena "Best pricing strategy for a developer tool?"
```

[Read more →](./plugins/expert-arena/README.md)

---

## Troubleshooting Updates

If you don't see the latest version after update:

```bash
rm -rf ~/.claude/plugins/cache/izteam/
```

Then reinstall the plugin. Also enable auto-update for the marketplace:

```
/plugin > Marketplaces > izteam > Enable auto-update
```

## License

MIT — originally based on [ilia-izmailov-plugins](https://github.com/izmailovilya/ilia-izmailov-plugins) by Ilya Izmailov.
