<div align="center">

# 🧠 think-through

**Глубокий структурированный анализ с параллельными экспертами перед реализацией**

[![izteam](https://img.shields.io/badge/Marketplace-izteam-blue?style=flat&colorA=18181B&colorB=28CF8D)](https://github.com/izzzzzi/izteam)
[![Version](https://img.shields.io/badge/Version-1.1.0-blue?style=flat&colorA=18181B&colorB=7C3AED)](https://github.com/izzzzzi/izteam)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat&colorA=18181B&colorB=28CF8D)](../../LICENSE)

<br />

*Разбивает задачу на аспекты, запускает экспертов параллельно и создаёт структурированный документ с решениями, trade-offs и планом реализации.*

</div>

---

## 🚀 Установка

```bash
/plugin marketplace add izzzzzi/izteam
/plugin install think-through@izteam
```

---

## ✨ Использование

```bash
/deep-thinking <задача или идея>
```

**Примеры:**

```bash
# Новая фича
/deep-thinking Implement a feedback collection system with cashback rewards

# Архитектурное решение
/deep-thinking Migrate from REST to GraphQL — trade-offs and strategy

# Рефакторинг
/deep-thinking Refactor authentication from session-based to JWT

# Любой домен
/deep-thinking Best approach to gamification in a fitness app
```

---

## 📖 Как это работает

### Stage 1 — Breakdown + Expert Perspective

| Шаг | Что происходит |
|-----|---------------|
| Понимание задачи | 1-2 предложения — как агент понял задачу |
| Выбор главного эксперта | С объяснением почему именно он |
| 3 принципа | От трёх экспертов-смежников |
| Таблица аспектов | 5-15 аспектов, каждый с назначенным экспертом |

**Примеры экспертов:**

| Область | Эксперт | Принципы |
|---------|---------|----------|
| React/State | Dan Abramov | Single responsibility, colocation |
| TypeScript | Matt Pocock | Infer over explicit, type narrowing |
| Architecture | Sam Newman | Bounded context, loose coupling |
| Security | Troy Hunt | Defense in depth, least privilege |
| UX/Product | Nir Eyal | Trigger → action → reward → investment |

### Stage 2 — Parallel Expert Analysis

Запускает агентов параллельно — **один эксперт на аспект**. Каждый агент:

1. Изучает проект (структура, паттерны, существующий код)
2. Применяет экспертное мышление
3. Предлагает 2-4 варианта решения с pros/cons
4. Даёт рекомендацию от лица эксперта

### Stage 3 — Summary Document

Собирает результаты в единый документ:

```markdown
# Task Name

## Overview
### Goals, Key Decisions

## 1. Aspect Name
> Experts: [Expert 1], [Expert 2], [Expert 3]
### Solution details, code examples

## Implementation Plan
### Phase 1: MVP, Phase 2: ...

## Success Metrics
| Metric | Baseline | Target |
```

Сохраняется в `docs/plans/YYYY-MM-DD-[topic]-design.md`

---

## 🎯 Когда использовать

| Ситуация | Пример |
|----------|--------|
| Новая фича с неочевидными решениями | "Система уведомлений с real-time" |
| Рефакторинг с выбором подхода | "Миграция на новый ORM" |
| Архитектурные изменения | "Переход на микросервисы" |
| Любая задача где "надо подумать" | "Как правильно реализовать кеширование?" |

---

## 📁 Структура

```
think-through/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   └── deep-thinking/
│       └── SKILL.md         # /deep-thinking команда
├── agents/
│   └── expert.md            # Агент-эксперт (один на аспект)
└── README.md
```

---

## 📝 Лицензия

[MIT](../../LICENSE)
