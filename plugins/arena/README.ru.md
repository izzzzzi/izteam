<p align="right"><a href="./README.md">English</a> | <strong>Русский</strong></p>

# Arena

Сравнивайте экспертные точки зрения и приходите к чёткому решению.

## Prerequisites

> **Agent Teams экспериментальны и по умолчанию выключены.** Перед использованием плагина их нужно включить.

Добавьте `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` в `settings.json` или окружение:

```json
// ~/.claude/settings.json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Или задайте переменную окружения:

```bash
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

После включения перезапустите Claude Code.

## Installation

```bash
/plugin marketplace add izzzzzi/izTeam
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

Подходит для любых доменов: engineering, product, strategy, business, science, philosophy.

## How It Works

```mermaid
flowchart TD
    P0["Фаза 0: Подбор экспертов<br/>3-5 реальных экспертов + Адвокат дьявола"]
    P1["Фаза 1: Разведка<br/>2-4 researcher параллельно"]
    P2["Фаза 2: Запуск арены<br/>Briefing packet + Agent Team"]
    P3["Фаза 3: Органические дебаты<br/>Эксперты спорят peer-to-peer"]
    P4{"Фаза 4: Конвергенция<br/>Консенсус стабилизировался?"}
    P5["Фаза 5: Синтез<br/>Вердикт + план действий"]
    DOC["docs/arena/YYYY-MM-DD-topic.md"]

    P0 --> P1 --> P2 --> P3 --> P4
    P4 -->|Нет| P3
    P4 -->|Да| P5 --> DOC
```

Во время дебатов: эксперты дают позицию с самокритикой, оспаривают аргументы друг друга, меняют позицию при убедительных доводах. Адвокат дьявола может наложить вето на критические изъяны. Модератор комментирует ключевые моменты в реальном времени.

## Structure

```
arena/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   └── arena/
│       ├── SKILL.md
│       └── references/
│           ├── expert-selection-guide.md
│           ├── live-commentary-rules.md
│           └── synthesis-template.md
├── agents/
│   ├── expert.md
│   └── researcher.md
├── README.md
└── README.ru.md
```

## Key Design Principles

| Принцип | Зачем |
|---------|-------|
| **Реальные люди** | Эксперты основаны на реальных публичных позициях |
| **Намеренный конфликт** | Противоположные мнения вскрывают скрытые допущения |
| **Прямая коммуникация** | Эксперты спорят peer-to-peer |
| **Смена позиции = сила** | Сильные аргументы могут менять позицию |
| **Адвокат дьявола с вето** | Защита от группового мышления |
| **Live commentary** | Вы видите эволюцию рассуждений в реальном времени |

## When to Use

- Архитектурные или стратегические решения с высокой ставкой
- Trade-offs без очевидного правильного ответа
- Ситуации, где нужны разные экспертные взгляды
- Stress-test идей перед фиксацией решения
- Вопросы, где обоснованные эксперты могут не согласиться

## License

MIT
