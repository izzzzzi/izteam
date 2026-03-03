<p align="right"><strong>English</strong> | <a href="./CONTRIBUTING.ru.md">Русский</a></p>

# Contributing to izteam

Thank you for your interest in contributing! This guide will help you get started.

## Getting Started

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/<your-username>/izTeam.git
   cd izTeam
   ```
3. Create a feature branch:
   ```bash
   git checkout -b feat/my-feature
   ```

## Project Structure

```text
izteam/
├── .claude-plugin/       # Marketplace manifest
│   └── marketplace.json
├── plugins/              # All plugins live here
│   ├── team/             # /build, /brief, /conventions
│   ├── think/            # /think
│   ├── arena/            # /arena
│   └── audit/            # /audit
├── scripts/              # Dev scripts
│   └── bump-version.sh
└── .github/workflows/    # CI/CD
```

Each plugin follows the same layout:

```text
plugins/<name>/
├── plugin.json           # Plugin manifest (name, version, skills)
├── agents/               # Agent definitions (.md)
├── skills/               # Slash-command skills
│   └── <skill>/
│       ├── skill.md      # Skill prompt
│       └── references/   # Reference files loaded by the skill
├── README.md             # English docs
└── README.ru.md          # Russian docs
```

## How to Contribute

### Bug Reports

Open an issue with:
- Steps to reproduce
- Expected vs actual behavior
- Claude Code version and OS

### Feature Requests

Open an issue describing:
- The problem you're trying to solve
- Your proposed solution
- Which plugin it relates to (or if it's a new plugin)

### Pull Requests

1. Follow [Conventional Commits](https://www.conventionalcommits.org/):
   - `feat:` — new feature
   - `fix:` — bug fix
   - `docs:` — documentation only
   - `chore:` — maintenance, CI, scripts
   - `refactor:` — code restructuring without behavior change

2. Keep PRs focused — one logical change per PR.

3. Update documentation if your change affects user-facing behavior.

4. Test your plugin changes locally:
   ```bash
   # Install from your local branch
   /plugin marketplace add <your-username>/izTeam --branch feat/my-feature
   /plugin install <plugin-name>@izteam
   ```

### Creating a New Plugin

1. Create `plugins/<name>/plugin.json` with required fields:
   ```json
   {
     "name": "<name>",
     "version": "0.1.0",
     "description": "Short description",
     "skills": []
   }
   ```

2. Add the plugin to `.claude-plugin/marketplace.json`.

3. Add `README.md` and `README.ru.md` for documentation.

4. Add a section in the root `README.md` and `README.ru.md`.

## Versioning

Versions are bumped automatically via CI from Conventional Commits.
To bump manually:

```bash
./scripts/bump-version.sh <plugin> patch|minor|major
```

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md).
