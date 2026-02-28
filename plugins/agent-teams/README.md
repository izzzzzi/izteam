<div align="center">

# 🤖 agent-teams

**Команда AI-агентов для реализации фич с code review gates, risk analysis и always-on Supervisor**

[![izteam](https://img.shields.io/badge/Marketplace-izteam-blue?style=flat&colorA=18181B&colorB=28CF8D)](https://github.com/izzzzzi/izteam)
[![Version](https://img.shields.io/badge/Version-0.3.0-blue?style=flat&colorA=18181B&colorB=7C3AED)](https://github.com/izzzzzi/izteam)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat&colorA=18181B&colorB=28CF8D)](../../LICENSE)

<br />

*Запускает полноценную команду разработчиков — исследователи изучают проект, кодеры реализуют по gold standard примерам, 3 ревьюера проверяют каждое изменение, Tech Lead валидирует архитектуру.*

</div>

---

## 📋 Требования

> Agent Teams — экспериментальная фича Claude Code, отключена по умолчанию.

```json
// ~/.claude/settings.json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Перезапустите Claude Code после включения.

---

## 🚀 Установка

```bash
/plugin marketplace add izzzzzi/izteam
/plugin install agent-teams@izteam
```

---

## ✨ Команды

| Команда | Описание |
|---------|----------|
| `/team-feature <описание>` | Запуск команды для реализации фичи |
| `/team-feature plan.md --coders=2` | Из файла плана с N кодерами |
| `/interviewed-team-feature <тема>` | Интервью перед реализацией (2-6 вопросов) |
| `/conventions [path]` | Анализ и создание конвенций проекта |

---

## 📖 Как это работает

### Phase 1 — Discovery & Planning

<details>
<summary><b>Step 1: Parallel Research</b></summary>

Два исследователя работают одновременно:

| Агент | Что делает | Что возвращает |
|-------|-----------|---------------|
| **Codebase Researcher** | Сканирует структуру, стек, паттерны | Сжатый summary проекта |
| **Reference Researcher** | Находит лучшие примеры кода по слоям | Полное содержимое файлов (gold standards) |

Gold standards — это реальные файлы из вашего проекта, которые кодеры используют как образец. Это повышает консистентность кода на 15-40% по сравнению с текстовыми инструкциями.

</details>

<details>
<summary><b>Step 2: Complexity Classification</b></summary>

| Уровень | Когда | Команда |
|---------|-------|---------|
| **SIMPLE** | 1 слой, <3 задач | 4 агента, 1 unified reviewer |
| **MEDIUM** | 2+ слоя, модификация кода | 5-7 агентов, 3 ревьюера, risk analysis |
| **COMPLEX** | 3 слоя, auth/payments | 6-9+ агентов, deep analysis, risk testers |

</details>

<details>
<summary><b>Step 3: Plan Validation (MEDIUM/COMPLEX)</b></summary>

Tech Lead проверяет план до написания кода:
- Задачи правильно разбиты? (один файл = один кодер)
- Зависимости выставлены верно?
- Подход соответствует архитектуре?

</details>

<details>
<summary><b>Step 4: Risk Analysis (MEDIUM/COMPLEX)</b></summary>

Risk Testers проверяют потенциальные проблемы:

| Risk Analysis (до кода) | Review (после кода) |
|--------------------------|---------------------|
| "Миграция удалит данные" | "Синтаксическая ошибка в миграции" |
| "Auth middleware не покроет новые роуты" | "Auth check отсутствует на строке 42" |

</details>

### Phase 2 — Execution

<details>
<summary><b>Step 5: Coding with Gold Standards</b></summary>

Каждый кодер:
1. Читает gold standards и reference files
2. Реализует по тем же паттернам
3. Запускает self-checks (build, lint, types)
4. Отправляет на review

</details>

<details>
<summary><b>Step 6-7: Convention Checks + Specialized Review</b></summary>

**SIMPLE** — Unified Reviewer проверяет всё в один проход. Эскалация в MEDIUM при обнаружении sensitive кода.

**MEDIUM / COMPLEX** — три ревьюера параллельно:

| Ревьюер | Что ловит | Примеры |
|---------|----------|---------|
| 🔒 **Security** | Уязвимости | SQL injection, XSS, auth bypass, IDOR |
| 🧠 **Logic** | Баги | Race conditions, off-by-one, null handling |
| 📐 **Quality** | Поддерживаемость | DRY violations, нейминг, конвенции |

</details>

<details>
<summary><b>Step 8: Architectural Approval</b></summary>

Tech Lead даёт финальный sign-off:
- Вписывается в общую архитектуру?
- Консистентно с другими задачами?
- Нет cross-task конфликтов?

</details>

### Phase 3 — Completion

<details>
<summary><b>Steps 9-11: Integration, Conventions, Report</b></summary>

```
══════════════════════════════════════════════════
FEATURE IMPLEMENTATION COMPLETE
══════════════════════════════════════════════════
Tasks completed: 4/4
Complexity: MEDIUM
Commits: [list]

Risk analysis: 3 risks identified, 1 confirmed & mitigated
Review stats: 2 security, 1 logic, 3 quality issues fixed
Integration: Build ✅ Tests ✅
Conventions: 2 gold standards added
══════════════════════════════════════════════════
```

</details>

---

## 👥 Роли в команде

| Роль | Тип | Назначение |
|------|-----|------------|
| **Lead** | Постоянный | Оркестрирует пайплайн, защищает свой контекст делегированием |
| **Supervisor** | Постоянный | Мониторинг liveness, детект loops/deadlocks, эскалации |
| **Tech Lead** | Постоянный | Валидация плана, архитектурный review, DECISIONS.md |
| **Coder** | Per task | Реализация по gold standards, self-checks |
| **Security Reviewer** | Постоянный | Injection, XSS, auth bypass, secrets, IDOR |
| **Logic Reviewer** | Постоянный | Race conditions, edge cases, null, async |
| **Quality Reviewer** | Постоянный | DRY, нейминг, абстракции, конвенции |
| **Unified Reviewer** | Постоянный | Всё-в-одном для SIMPLE задач |
| **Risk Tester** | One-shot | Проверка рисков до написания кода |
| **Codebase Researcher** | One-shot | Сжатый summary проекта |
| **Reference Researcher** | One-shot | Полное содержимое gold standard файлов |

---

## 📁 Структура

```
agent-teams/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   ├── team-feature/SKILL.md
│   ├── conventions/SKILL.md
│   └── interviewed-team-feature/
│       ├── SKILL.md
│       └── references/interview-principles.md
├── agents/
│   ├── supervisor.md
│   ├── tech-lead.md
│   ├── coder.md
│   ├── codebase-researcher.md
│   ├── reference-researcher.md
│   ├── security-reviewer.md
│   ├── logic-reviewer.md
│   ├── quality-reviewer.md
│   ├── unified-reviewer.md
│   └── risk-tester.md
├── references/
│   ├── reviewer-protocol.md
│   ├── gold-standard-template.md
│   ├── risk-testing-example.md
│   └── status-icons.md
└── README.md
```

---

## 📝 Лицензия

[MIT](../../LICENSE)
