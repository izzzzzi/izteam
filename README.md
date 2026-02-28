<div align="center">

# 🧩 izteam

**Коллекция плагинов для Claude Code — команды AI-агентов, экспертные дебаты, глубокий анализ и аудит кода**

[![Validate](https://github.com/izzzzzi/izteam/actions/workflows/validate.yml/badge.svg)](https://github.com/izzzzzi/izteam/actions/workflows/validate.yml)
[![Release](https://github.com/izzzzzi/izteam/actions/workflows/release.yml/badge.svg)](https://github.com/izzzzzi/izteam/actions/workflows/release.yml)
[![Auto Version](https://github.com/izzzzzi/izteam/actions/workflows/auto-version.yml/badge.svg)](https://github.com/izzzzzi/izteam/actions/workflows/auto-version.yml)
[![Plugins](https://img.shields.io/badge/Plugins-4-blue?style=flat&colorA=18181B&colorB=28CF8D)](https://github.com/izzzzzi/izteam)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat&colorA=18181B&colorB=28CF8D)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude_Code-Plugin-purple?style=flat&colorA=18181B&colorB=7C3AED)](https://claude.ai/code)

<br />

*Marketplace плагинов, превращающих Claude Code в мультиагентную систему — с командами разработчиков, специализированными ревьюерами и экспертными советами.*

</div>

---

## 📖 Обзор

**izteam** — независимый marketplace плагинов для [Claude Code](https://claude.ai/code).
Каждый плагин добавляет slash-команды, агентов и готовые пайплайны: от оркестрации целой команды AI-разработчиков до глубокого аудита кодовой базы.

---

## ✨ Плагины

| Плагин | Версия | Описание | Команда |
|--------|--------|----------|---------|
| 🤖 **[team](#-team)** | `0.3.0` | Команда AI-агентов с code review gates | `/build` |
| 🧠 **[think](#-think)** | `1.1.0` | Глубокий анализ перед реализацией | `/think` |
| 🎭 **[arena](#-arena)** | `1.1.0` | Экспертные дебаты для сложных решений | `/arena` |
| 🧹 **[audit](#-audit)** | `0.1.0` | Интерактивный аудит мёртвого кода | `/audit` |

---

## 🚀 Быстрый старт

### 1. Добавь marketplace

```bash
/plugin marketplace add izzzzzi/izteam
```

### 2. Установи плагины

```bash
/plugin install team@izteam
/plugin install think@izteam
/plugin install arena@izteam
/plugin install audit@izteam
```

### 3. Перезапусти Claude Code

Плагины загружаются при старте — перезапусти после установки.

---

## 🤖 team

Запускает команду AI-агентов для реализации фич с встроенными code review gates.

> **Требуется:** `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` в settings.json

```bash
/plugin install team@izteam
```

**Примеры:**

```bash
/build "Добавить страницу настроек пользователя"
/build docs/plan.md --coders=2
/brief "Система уведомлений"
/conventions
```

[Подробнее →](./plugins/team/README.md)

---

## 🧠 think

Глубокий структурированный анализ перед реализацией — разбиение на аспекты, параллельные эксперты, итоговый документ.

```bash
/plugin install think@izteam
```

**Примеры:**

```bash
/think Implement a feedback collection system with cashback rewards
/think Migrate from REST to GraphQL — trade-offs and strategy
/think Refactor authentication from session-based to JWT
```

[Подробнее →](./plugins/think/README.md)

---

## 🎭 arena

Арена экспертных дебатов — реальные эксперты спорят напрямую и приходят к конвергенции.

> **Требуется:** `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` в settings.json

```bash
/plugin install arena@izteam
```

**Примеры:**

```bash
/arena Should we use microservices or monolith for our SaaS?
/arena Best pricing strategy for a developer tool?
/arena How should we handle state management in our React app?
```

[Подробнее →](./plugins/arena/README.md)

---

## 🧹 audit

Интерактивный аудит для vibe-coded проектов — находит мёртвый код через диалог с разработчиком.

```bash
/plugin install audit@izteam
```

**Примеры:**

```bash
/audit
/audit features
/audit server
/audit ui
/audit stores
```

[Подробнее →](./plugins/audit/README.md)

---

## 📁 Структура проекта

```text
izteam/
├── .claude-plugin/
│   └── marketplace.json
├── plugins/
│   ├── team/
│   ├── think/
│   ├── arena/
│   └── audit/
├── scripts/
│   └── bump-version.sh
├── .github/workflows/
│   ├── validate.yml
│   ├── release.yml
│   └── auto-version.yml
└── LICENSE
```

---

## 🔧 Настройка

### Включение Agent Teams

Плагины `team` и `arena` требуют экспериментальную функцию Agent Teams:

```json
// ~/.claude/settings.json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

---

## 🛠 Разработка

### Версионирование

```bash
# Бамп patch-версии
./scripts/bump-version.sh team patch

# Бамп minor-версии
./scripts/bump-version.sh think minor
```

Скрипт синхронно обновляет `plugin.json` и `.claude-plugin/marketplace.json`.

### CI/CD

- `validate.yml` — проверки структуры и консистентности
- `release.yml` — релизный pipeline
- `auto-version.yml` — автоматический бамп версий по Conventional Commits

---

## 🐛 Troubleshooting

- Плагин не появился после установки → перезапусти Claude Code.
- Не подтянулась новая версия → очисти кеш:

```bash
rm -rf ~/.claude/plugins/cache/izteam/
```

---

## 📝 Лицензия

[MIT](LICENSE)
