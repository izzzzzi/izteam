<div align="center">

# 🧩 izteam

**Коллекция плагинов для Claude Code — команды AI-агентов, экспертные дебаты, глубокий анализ и аудит кода**

[![Validate](https://github.com/izzzzzi/izteam/actions/workflows/validate.yml/badge.svg)](https://github.com/izzzzzi/izteam/actions/workflows/validate.yml)
[![Release](https://github.com/izzzzzi/izteam/actions/workflows/release.yml/badge.svg)](https://github.com/izzzzzi/izteam/actions/workflows/release.yml)
[![Plugins](https://img.shields.io/badge/Plugins-4-blue?style=flat&colorA=18181B&colorB=28CF8D)](https://github.com/izzzzzi/izteam)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat&colorA=18181B&colorB=28CF8D)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude_Code-Plugin-purple?style=flat&colorA=18181B&colorB=7C3AED)](https://claude.ai/code)

<br />

*Marketplace плагинов, превращающих Claude Code в мультиагентную систему — с командами разработчиков, специализированными ревьюерами и экспертными советами.*

</div>

---

## 📖 Обзор

**izteam** — это независимый marketplace плагинов для [Claude Code](https://claude.ai/code). Каждый плагин добавляет slash-команды, агентов и скиллы — от оркестрации целых команд AI-разработчиков до глубокого аудита кодовой базы.

---

## ✨ Плагины

| Плагин | Версия | Описание | Команда |
|--------|--------|----------|---------|
| 🤖 **[agent-teams](#-agent-teams)** | `0.3.0` | Команда AI-агентов с code review gates | `/team-feature` |
| 🧠 **[think-through](#-think-through)** | `1.1.0` | Глубокий анализ перед реализацией | `/deep-thinking` |
| 🎭 **[expert-arena](#-expert-arena)** | `1.1.0` | Экспертные дебаты для сложных решений | `/expert-arena` |
| 🧹 **[vibe-audit](#-vibe-audit)** | `0.1.0` | Интерактивный аудит мёртвого кода | `/vibe-audit` |

---

## 🚀 Быстрый старт

### 1. Добавь marketplace

```bash
/plugin marketplace add izzzzzi/izteam
```

### 2. Установи нужный плагин

```bash
/plugin install agent-teams@izteam
/plugin install think-through@izteam
/plugin install expert-arena@izteam
/plugin install vibe-audit@izteam
```

### 3. Перезапусти Claude Code

Плагины загружаются при старте — перезапусти после установки.

---

## 🤖 agent-teams

Запускает команду AI-агентов для реализации фич с встроенными code review gates.

> **Требуется:** `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` в settings.json

```bash
/plugin install agent-teams@izteam
```

<details>
<summary><b>Примеры использования</b></summary>

```bash
# Описание фичи текстом
/team-feature "Добавить страницу настроек пользователя"

# План из файла + 2 кодера
/team-feature docs/plan.md --coders=2

# Интервью перед реализацией
/interviewed-team-feature "Система уведомлений"

# Анализ и создание конвенций проекта
/conventions
```

</details>

<details>
<summary><b>Как это работает</b></summary>

**Phase 1 — Discovery & Planning:**
- Два исследователя параллельно изучают кодовую базу
- Complexity Classification (SIMPLE → MEDIUM → COMPLEX)
- Tech Lead валидирует план
- Risk Testers проверяют потенциальные проблемы

**Phase 2 — Execution:**
- Coders реализуют по gold standard примерам из вашего проекта
- Supervisor мониторит здоровье команды 24/7
- 3 специализированных ревьюера (Security + Logic + Quality)
- Tech Lead даёт финальный архитектурный approval

**Phase 3 — Completion:**
- Интеграционные тесты
- Обновление `.conventions/`
- Summary report со статистикой

</details>

<details>
<summary><b>Роли в команде</b></summary>

| Роль | Тип | Назначение |
|------|-----|------------|
| **Lead** | Постоянный | Оркестрирует весь пайплайн |
| **Supervisor** | Постоянный | Мониторинг, детект deadlock-ов, эскалации |
| **Tech Lead** | Постоянный | Валидация плана и архитектуры |
| **Coder** | Per task | Реализация по gold standard паттернам |
| **Security Reviewer** | Постоянный | Инъекции, XSS, auth bypass, IDOR |
| **Logic Reviewer** | Постоянный | Race conditions, edge cases, null handling |
| **Quality Reviewer** | Постоянный | DRY, нейминг, абстракции, конвенции |
| **Risk Tester** | One-shot | Проверка рисков до написания кода |

</details>

[Подробнее →](./plugins/agent-teams/README.md)

---

## 🧠 think-through

Глубокий структурированный анализ перед реализацией — разбиение на аспекты, параллельные эксперты, итоговый документ.

```bash
/plugin install think-through@izteam
```

<details>
<summary><b>Примеры использования</b></summary>

```bash
# Анализ перед новой фичей
/deep-thinking Implement a feedback collection system with cashback rewards

# Архитектурные решения
/deep-thinking Migrate from REST to GraphQL — trade-offs and strategy

# Рефакторинг
/deep-thinking Refactor authentication from session-based to JWT
```

</details>

<details>
<summary><b>Как это работает</b></summary>

| Этап | Что происходит |
|------|---------------|
| **1. Breakdown** | Разбиение задачи на аспекты, выбор главного эксперта + 3 принципа |
| **2. Parallel Analysis** | Запуск агентов параллельно — один эксперт на аспект, каждый изучает проект |
| **3. Summary** | Единый документ: решения, trade-offs, код, план реализации, метрики |

Результат сохраняется в `docs/plans/YYYY-MM-DD-[topic]-design.md`

</details>

[Подробнее →](./plugins/think-through/README.md)

---

## 🎭 expert-arena

Арена экспертных дебатов — реальные эксперты спорят напрямую друг с другом и приходят к конвергенции.

> **Требуется:** `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` в settings.json

```bash
/plugin install expert-arena@izteam
```

<details>
<summary><b>Примеры использования</b></summary>

```bash
# Архитектурные решения
/expert-arena Should we use microservices or monolith for our SaaS?

# Продуктовые решения
/expert-arena Best pricing strategy for a developer tool?

# Технические trade-offs
/expert-arena How should we handle state management in our React app?
```

</details>

<details>
<summary><b>Как это работает</b></summary>

| Фаза | Что происходит |
|------|---------------|
| **0. Expert Selection** | Подбор 3-5 реальных экспертов с противоположными позициями |
| **1. Reconnaissance** | 2-4 исследователя собирают данные параллельно |
| **2. Arena Launch** | Все эксперты стартуют одновременно с полным контекстом |
| **3. Organic Debates** | Прямые дебаты peer-to-peer, Devil's Advocate с правом вето |
| **4. Convergence** | Эксперты приходят к финальным позициям |
| **5. Synthesis** | Итоговый документ: вердикт, хроника дебатов, план действий |

Результат сохраняется в `docs/arena/YYYY-MM-DD-[topic].md`

</details>

[Подробнее →](./plugins/expert-arena/README.md)

---

## 🧹 vibe-audit

Интерактивный аудит для vibe-coded проектов — находит мёртвый код через диалог с разработчиком.

```bash
/plugin install vibe-audit@izteam
```

<details>
<summary><b>Примеры использования</b></summary>

```bash
# Полный скан
/vibe-audit

# Специализированные аудиты
/vibe-audit features     # src/features/ — мёртвые экспорты
/vibe-audit server       # src/server/ — неиспользуемые роуты
/vibe-audit ui           # src/design-system/ — забытые компоненты
/vibe-audit stores       # src/stores/ — мёртвые Zustand слайсы
```

</details>

<details>
<summary><b>Как это работает</b></summary>

```
1. DISCOVERY       →  Агент сканирует и находит подозрительные области
2. INTERVIEW       →  Спрашивает: "Это нужно?" [ 🗑️ Удалить | ✅ Нужно | 🤔 Не уверен ]
3. CLEANUP         →  Безопасное удаление с git branch + TypeScript check
```

**Что ищет:**
- Orphan routes — tRPC без вызовов с клиента
- Dead UI — компоненты без импортов
- Isolated features — папки с минимальными связями
- Stale code — нет коммитов 30+ дней
- Duplicate patterns — похожая логика в разных местах

</details>

[Подробнее →](./plugins/vibe-audit/README.md)

---

## 📁 Структура проекта

```
izteam/
├── .claude-plugin/
│   └── marketplace.json          # Реестр плагинов
├── plugins/
│   ├── agent-teams/              # 🤖 Команды AI-агентов
│   │   ├── agents/               #    11 специализированных агентов
│   │   ├── skills/               #    team-feature, conventions
│   │   └── references/           #    Протоколы, шаблоны, иконки
│   ├── think-through/            # 🧠 Глубокий анализ
│   │   ├── agents/               #    Эксперт-аналитик
│   │   └── skills/               #    deep-thinking
│   ├── expert-arena/             # 🎭 Экспертные дебаты
│   │   ├── agents/               #    Эксперт, исследователь
│   │   └── skills/               #    expert-arena
│   └── vibe-audit/               # 🧹 Аудит мёртвого кода
│       ├── agents/               #    6 специализированных аудиторов
│       └── skills/               #    vibe-audit
├── scripts/
│   └── bump-version.sh           # Скрипт версионирования
├── .github/workflows/
│   ├── validate.yml              # Валидация JSON + версий
│   └── release.yml               # Авто-теги + GitHub Releases
└── LICENSE
```

---

## 🔧 Настройка

### Включение экспериментальных команд

Плагины `agent-teams` и `expert-arena` требуют Agent Teams:

```json
// ~/.claude/settings.json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

### Включение auto-update

```
/plugin > Marketplaces > izteam > Enable auto-update
```

---

## 🐛 Troubleshooting

<details>
<summary><b>Плагин не появляется после установки</b></summary>

Перезапустите Claude Code — плагины загружаются при старте.

</details>

<details>
<summary><b>Не обновляется до новой версии</b></summary>

Очистите кеш и переустановите:

```bash
rm -rf ~/.claude/plugins/cache/izteam/
```

Затем: `/plugin install <plugin-name>@izteam`

</details>

<details>
<summary><b>agent-teams / expert-arena не работают</b></summary>

Убедитесь что включён флаг:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Файл: `~/.claude/settings.json` — перезапустите Claude Code после изменения.

</details>

---

## 🛠 Разработка

### Версионирование

```bash
# Бамп patch-версии (0.3.0 → 0.3.1)
./scripts/bump-version.sh agent-teams patch

# Бамп minor-версии (1.1.0 → 1.2.0)
./scripts/bump-version.sh think-through minor
```

Скрипт обновляет `plugin.json` и `marketplace.json` одновременно.

### CI/CD

- **validate.yml** — проверяет JSON-структуру и консистентность версий на каждый PR и push
- **release.yml** — автоматически создаёт git tag и GitHub Release при изменении плагина

---

## 📝 Лицензия

[MIT](LICENSE) — основано на [ilia-izmailov-plugins](https://github.com/izmailovilya/ilia-izmailov-plugins) by Ilya Izmailov.

<div align="center">
<br />

*Сделано с помощью Claude Code*

</div>
