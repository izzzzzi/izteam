<p align="right"><a href="./README.md">English</a> | <strong>Русский</strong></p>

# Think

Планируйте сложные задачи до кодинга через структурированный экспертный анализ.

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
- Уточняет задачу и целевой результат
- Выбирает главного эксперта с обоснованием
- Берёт guiding principles от 3 экспертов
- Формирует таблицу аспектов для анализа (с назначенными экспертами)

### Stage 2: Parallel Expert Analysis
Запускает агентов параллельно — по одному на аспект. Каждый агент:
- Изучает проект (структура, паттерны, существующий код)
- Применяет экспертное мышление (main expert + principles)
- Предлагает 2-4 варианта с плюсами и минусами
- Даёт рекомендацию по своему аспекту

### Stage 3: Summary Document
Собирает результаты в один структурированный markdown-документ:
- Table of contents
- Overview с ключевыми решениями
- Детали по каждому аспекту с comparison tables
- Implementation plan по фазам
- Success metrics

Сохраняет в `docs/plans/YYYY-MM-DD-[topic]-design.md`

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

Планирующий документ, который включает:
- Список экспертов по разделам
- Decision tables
- Code examples
- Поэтапный implementation plan
- Success metrics

## When to Use

- Новые фичи с неочевидными решениями
- Рефакторинг, где есть несколько подходов
- Архитектурные изменения
- Любые задачи, где важно продумать решение до кодинга

## License

MIT
