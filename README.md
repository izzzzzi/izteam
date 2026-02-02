# Ilya Izmailov's Claude Code Plugins

A collection of plugins for [Claude Code](https://claude.ai/code).

## Installation

Add this marketplace to Claude Code:

```bash
/plugin marketplace add izmailovilya/ilia-izmailov-plugins
```

Then install any plugin:

```bash
/plugin install <plugin-name>@ilia-izmailov-plugins
```

**Important:** Restart Claude Code after installing plugins to load them.

## Available Plugins

### think-through

Deep structured thinking with parallel expert analysis before implementation.

```bash
/plugin install think-through@ilia-izmailov-plugins
```

**Usage:**
```
/deep-thinking <task or idea>
```

Breaks down your task into aspects, launches expert agents in parallel (🐙), and produces a comprehensive design document with decisions, trade-offs, and implementation plan.

[Read more →](./plugins/think-through/README.md)

---

### vibe-audit

Interactive feature audit for vibe-coded projects. Finds dead code, unused features, and experiments through conversation.

```bash
/plugin install vibe-audit@ilia-izmailov-plugins
```

**Usage:**
```
/vibe-audit              # Full codebase scan
/vibe-audit features     # src/features/ deep audit
/vibe-audit server       # src/server/ routers & services
/vibe-audit ui           # src/design-system/ components
/vibe-audit stores       # src/stores/ Zustand state
```

Scans your codebase for suspicious areas (orphan routes, dead UI, stale code), asks if you need them, and safely removes what you don't — with git backup.

[Read more →](./plugins/vibe-audit/README.md)

---

## License

MIT
