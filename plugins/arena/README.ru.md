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

Подходит для любых доменов: engineering, product, strategy, business, science, philosophy.

## How It Works

### Phase 0: Expert Selection
- Анализирует ваш вопрос (домен, тип, ставка решения)
- Выбирает 3-5 реальных экспертов с публичными позициями
- Обеспечивает конфликтующие точки зрения
- Добавляет Devil's Advocate с veto power
- Показывает панель экспертов для ревью

### Phase 1: Reconnaissance
- Запускает 2-4 researcher agents параллельно
- Собирает архитектурные ограничения, данные и кейсы
- Исследователи возвращают выводы и завершаются

### Phase 2: Arena Launch
- Собирает findings в briefing packet
- Создаёт Agent Team
- Запускает всех экспертов с общим контекстом

### Phase 3: Organic Debates
Эксперты спорят напрямую друг с другом:

1. Каждый эксперт даёт позицию и self-critique
2. Эксперты оспаривают аргументы друг друга
3. Контраргументы и смена позиции происходят естественно
4. Devil's Advocate может поднять veto при критических изъянах
5. Модератор даёт live commentary по ключевым моментам

### Phase 4: Convergence
Дебаты завершаются, когда консенсус стабилизируется, эксперты замолкают или срабатывает timeout.

### Phase 5: Synthesis
Формирует итоговый документ с:
- Verdict и рекомендацией
- Хроникой дебатов
- Аргументами за и против
- Оставшимися разногласиями
- Action plan

Сохраняет в `docs/arena/YYYY-MM-DD-[topic].md`

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
| **Real people** | Эксперты основаны на реальных публичных позициях |
| **Intentional conflict** | Противоположные мнения вскрывают скрытые допущения |
| **Direct communication** | Эксперты спорят peer-to-peer |
| **Position change = strength** | Сильные аргументы могут менять позицию |
| **Devil's Advocate with veto** | Защита от groupthink |
| **Live commentary** | Вы видите эволюцию рассуждений в реальном времени |

## When to Use

- Архитектурные или стратегические решения с высокой ставкой
- Trade-offs без очевидного правильного ответа
- Ситуации, где нужны разные экспертные взгляды
- Stress-test идей перед фиксацией решения
- Вопросы, где обоснованные эксперты могут не согласиться

## License

MIT
