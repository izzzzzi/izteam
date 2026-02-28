<p align="right"><strong>English</strong> | <a href="./README.ru.md">Русский</a></p>

# Arena

Compare expert viewpoints and converge on a clear decision.

## Prerequisites

> **Agent Teams are experimental and disabled by default.** Enable them before using this plugin.

Add `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` to your `settings.json` or environment:

```json
// ~/.claude/settings.json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Or set the environment variable:

```bash
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

Restart Claude Code after enabling.

## Installation

```bash
/plugin marketplace add izzzzzi/izteam
/plugin install arena@izteam
```

## Usage

```
/arena <question>
```

**Examples:**
```
/arena Should we use microservices or monolith for our SaaS?
/arena What's the best pricing strategy for a developer tool?
/arena How should we handle state management in our React app?
```

Works for any domain: engineering, product, strategy, business, science, philosophy.

## How It Works

### Phase 0: Expert Selection
- Analyzes your question (domain, type, stakes)
- Selects 3-5 real experts with published positions
- Ensures opposing viewpoints
- Includes a Devil's Advocate with veto power
- Shows the panel for your review

### Phase 1: Reconnaissance
- Launches 2-4 researcher agents in parallel
- Collects architecture constraints, data points, and case studies
- Researchers return findings and exit

### Phase 2: Arena Launch
- Compiles findings into a briefing packet
- Creates an Agent Team
- Launches all experts with shared context

### Phase 3: Organic Debates
Experts debate directly with each other:

1. Each expert shares a position and self-critique
2. Experts challenge each other's arguments
3. Counter-arguments and position changes happen naturally
4. Devil's Advocate can raise a veto on critical flaws
5. Moderator provides live commentary on key turns

### Phase 4: Convergence
Debate ends when consensus stabilizes, experts go quiet, or timeout is reached.

### Phase 5: Synthesis
Creates a final document with:
- Verdict and recommendation
- Debate chronicle
- Arguments for and against
- Remaining disagreements
- Action plan

Saves to `docs/arena/YYYY-MM-DD-[topic].md`

## Structure

```
arena/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   └── arena/SKILL.md
├── agents/
│   ├── expert.md
│   └── researcher.md
├── README.md
└── README.ru.md
```

## Key Design Principles

| Principle | Why |
|-----------|-----|
| **Real people** | Experts are based on real published viewpoints |
| **Intentional conflict** | Opposing views expose hidden assumptions |
| **Direct communication** | Experts debate peer-to-peer |
| **Position change = strength** | Better arguments can change minds |
| **Devil's Advocate with veto** | Protects against groupthink |
| **Live commentary** | You can follow reasoning in real time |

## When to Use

- High-stakes architecture or strategy decisions
- Trade-offs without an obvious right answer
- Situations where you need diverse expert views
- Stress-testing ideas before committing
- Questions where informed experts may disagree

## License

MIT
