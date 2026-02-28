<p align="right"><strong>English</strong> | <a href="./README.ru.md">Русский</a></p>

# Think

Plan complex tasks before coding with structured expert analysis.

## Installation

```bash
/plugin marketplace add izzzzzi/izteam
/plugin install think@izteam
```

## Usage

```
/think <task or idea>
```

**Example:**
```
/think Implement a feedback collection system with cashback rewards
```

## How It Works

### Stage 1: Breakdown + Expert Perspective
- Clarifies the task and desired outcome
- Selects the main expert with reasoning
- Pulls guiding principles from 3 experts
- Creates a table of aspects to analyze (with assigned experts)

### Stage 2: Parallel Expert Analysis
Launches agents in parallel — one per aspect. Each agent:
- Studies your project (structure, patterns, existing code)
- Applies expert thinking (main expert + principles)
- Proposes 2-4 options with pros and cons
- Gives a recommendation for that aspect

### Stage 3: Summary Document
Combines results into one structured markdown document:
- Table of contents
- Overview with key decisions
- Details for each aspect with comparison tables
- Implementation plan by phases
- Success metrics

Saves to `docs/plans/YYYY-MM-DD-[topic]-design.md`

## Structure

```
think/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   └── think/SKILL.md
├── agents/
│   └── expert.md
├── README.md
└── README.ru.md
```

## Result

A planning document that includes:
- Experts used per section
- Decision tables
- Code examples
- Phased implementation plan
- Success metrics

## When to Use

- New features with many non-obvious decisions
- Refactoring where multiple approaches are possible
- Architectural changes
- Any task that needs careful planning before coding

## License

MIT
