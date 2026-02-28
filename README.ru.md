<p align="right"><a href="./README.md">English</a> | <strong>Русский</strong></p>

<div align="center">

# 🧩 izteam

**Маркетплейс плагинов для Claude Code: команды AI-агентов, экспертные дебаты, глубокое планирование и интерактивный аудит кода**

[![Validate](https://github.com/izzzzzi/izteam/actions/workflows/validate.yml/badge.svg)](https://github.com/izzzzzi/izteam/actions/workflows/validate.yml)
[![Release](https://github.com/izzzzzi/izteam/actions/workflows/release.yml/badge.svg)](https://github.com/izzzzzi/izteam/actions/workflows/release.yml)
[![Auto Version](https://github.com/izzzzzi/izteam/actions/workflows/auto-version.yml/badge.svg)](https://github.com/izzzzzi/izteam/actions/workflows/auto-version.yml)
[![Plugins](https://img.shields.io/badge/Plugins-4-blue?style=flat&colorA=18181B&colorB=28CF8D)](https://github.com/izzzzzi/izteam)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat&colorA=18181B&colorB=28CF8D)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude_Code-Plugin-purple?style=flat&colorA=18181B&colorB=7C3AED)](https://claude.ai/code)

<br />

*Установите прикладные плагины, которые делают работу Claude Code предсказуемее для разработки, принятия решений и очистки кода.*

</div>

---

## 📖 Обзор

**izteam** — независимый маркетплейс плагинов для [Claude Code](https://claude.ai/code).
Каждый плагин добавляет slash-команды, агентов и готовые workflow: от реализации фич командой AI-агентов до аудита устаревшего кода.

---

## ✨ Плагины

| Плагин | Версия | Описание | Команда |
|--------|--------|----------|---------|
| 🤖 **[team](#-team)** | `0.3.1` | Реализуйте фичи с командой AI-агентов и встроенными review-gates. | `/build` |
| 🧠 **[think](#-think)** | `1.1.1` | Планируйте сложные задачи до кодинга через структурированный экспертный анализ. | `/think` |
| 🎭 **[arena](#-arena)** | `1.1.1` | Сравнивайте экспертные точки зрения и приходите к чёткому решению. | `/arena` |
| 🧹 **[audit](#-audit)** | `0.1.1` | Находите мёртвый и устаревший код через интерактивный аудит. | `/audit` |

---

## 🚀 Быстрый старт

### 1. Добавьте marketplace

```bash
/plugin marketplace add izzzzzi/izteam
```

### 2. Установите плагины

```bash
/plugin install team@izteam
/plugin install think@izteam
/plugin install arena@izteam
/plugin install audit@izteam
```

### 3. Перезапустите Claude Code

Плагины загружаются при старте, поэтому после установки нужен перезапуск.

---

## 🤖 team

Build features with an AI agent team and built-in review gates.

> **Требуется:** `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` в `settings.json`

```bash
/plugin install team@izteam
```

**Примеры:**

```bash
/build "Add user settings page"
/build docs/plan.md --coders=2
/brief "Notifications system"
/conventions
```

[Подробнее (RU) →](./plugins/team/README.ru.md) · [EN →](./plugins/team/README.md)

---

## 🧠 think

Plan complex tasks before coding with structured expert analysis.

```bash
/plugin install think@izteam
```

**Примеры:**

```bash
/think Implement a feedback collection system with cashback rewards
/think Migrate from REST to GraphQL — trade-offs and strategy
/think Refactor authentication from session-based to JWT
```

[Подробнее (RU) →](./plugins/think/README.ru.md) · [EN →](./plugins/think/README.md)

---

## 🎭 arena

Compare expert viewpoints and converge on a clear decision.

> **Требуется:** `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` в `settings.json`

```bash
/plugin install arena@izteam
```

**Примеры:**

```bash
/arena Should we use microservices or monolith for our SaaS?
/arena Best pricing strategy for a developer tool?
/arena How should we handle state management in our React app?
```

[Подробнее (RU) →](./plugins/arena/README.ru.md) · [EN →](./plugins/arena/README.md)

---

## 🧹 audit

Find dead and outdated code with an interactive audit.

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

[Подробнее (RU) →](./plugins/audit/README.ru.md) · [EN →](./plugins/audit/README.md)

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
# Bump patch version
./scripts/bump-version.sh team patch

# Bump minor version
./scripts/bump-version.sh think minor
```

Скрипт обновляет `plugin.json` и `.claude-plugin/marketplace.json` синхронно.

### CI/CD

- `validate.yml` — проверки структуры и консистентности
- `release.yml` — release pipeline
- `auto-version.yml` — автоматический bump версий по Conventional Commits

---

## 🐛 Troubleshooting

- Плагин не появился после установки → перезапустите Claude Code.
- Новая версия не подтянулась → очистите кеш:

```bash
rm -rf ~/.claude/plugins/cache/izteam/
```

---

## 📝 Лицензия

[MIT](LICENSE)
