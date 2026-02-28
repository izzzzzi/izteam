# AssistAgents Integration Research

> **Status:** Phase 1 DONE. Phase 2 DONE.
> **Date:** 2026-02-28
> **Goal:** Прокачать research-агентов (think-through, expert-arena) через MCP интеграцию и улучшение методологии

---

## Table of Contents

1. [Overview](#overview)
2. [Research через MCP с фолбеками](#1-research-через-mcp-с-фолбеками)
3. [Архитектура фолбеков](#2-архитектура-фолбеков)
4. [Структура скиллов и агентов](#3-структура-скиллов-и-агентов)
5. [Уникальные возможности](#4-уникальные-возможности)
6. [Промпт-инженерия](#5-промпт-инженерия)
7. [План интеграции](#план-интеграции)

---

## Overview

### Что такое AssistAgents

Пакет агентов/скиллов для **OpenCode** (AI-IDE). Включает:
- 7 primary агентов + 3 субагента
- **86 скиллов** в 8 группах (project, planning, docs, testing, review, coder, task-use, shared)
- XML-structured промпты с нумерованными приоритетами
- 7 MCP-источников для research (Tavily, DuckDuckGo, Z.AI, Context7, GitHub Grep, DeepWiki)
- Install-time fallback: бесключевые MCP всегда доступны, платные — опционально
- Hash-based file tools (hashread/hashedit/hashgrep) для точных правок
- Init command — автодетекция стека и генерация проектных скиллов
- User profiling (skill_level, communication_style)

### Что наш проект уже делает лучше

| Аспект | Наш проект | AssistAgents |
|--------|-----------|--------------|
| Team orchestration | Supervisor FSM с epoch ownership, split-brain detection, teardown FSM | Нет аналога |
| Complexity classification | SIMPLE/MEDIUM/COMPLEX с mandatory triggers и разным составом команд | Binary fast/standard |
| Risk analysis | Risk testers с эмпирической верификацией ДО кода | Нет аналога |
| Review pipeline | 4 специализированных reviewer + escalation | 1 review agent |
| State management | state.md с single-writer rule, reconcile lock | Нет аналога |
| Conventions | Self-reinforcing gold-standards/anti-patterns/checks | Нет аналога |

### Ключевые решения (Phase 1 — ТОЛЬКО think-through + MCP)

| Аспект | Решение | Обоснование |
|--------|---------|-------------|
| MCP доступ для agents | **`tools` → `disallowedTools`** в frontmatter + Context7 в global scope | `tools` allowlist БЛОКИРУЕТ MCP даже если он global. `disallowedTools` наследует всё включая MCP |
| MCP серверы | **Context7 + GitHub Grep** в global scope | Context7 — highest value (library docs), GitHub Grep — code examples. DuckDuckGo redundant (WebSearch есть) |
| Bug #21560 | **Confirmed OPEN** (Feb 2026). Plugin MCP не работает для subagents | Workaround: global scope. v2.1.30 fix только для SDK MCP |
| Research methodology | **Улучшить expert.md** с structured steps + MCP tool-sniffing | 4 шага → 5 шагов, добавить MCP augmentation step |
| Phase blocks | **НЕ внедрять** `<collect>/<execute>/<verify>/<on_error>` | Текущие patterns + planned `<done_criteria>` достаточны |

### Deferred to Phase 2

| Аспект | Решение |
|--------|---------|
| Web Research методология в team-feature | Прокачать general-purpose prompt в SKILL.md |
| Структура промптов | `<done_criteria>`, priority markers, `<decision_policy>` в coder.md |
| Shared skills | `reviewer-protocol.md` — вынести дупликацию из 4 reviewers |
| Decision trees | ASCII decision trees в SKILL.md |
| Output contracts | Для codebase-researcher и reference-researcher |
| Init command | Расширить /conventions до project profile |

---

## 1. MCP Integration для think-through + expert-arena

> **Эксперты:** Sam Newman (Architecture), Martin Kleppmann (Distributed Systems)

### Проблема: Два барьера для MCP в plugin agents

**Барьер 1: Bug #21560 (confirmed OPEN, Feb 2026)**

Plugin-defined subagents НЕ МОГУТ использовать MCP tools из plugin `.mcp.json`.
- Issue [#21560](https://github.com/anthropics/claude-code/issues/21560) — open
- Issue [#27968](https://github.com/anthropics/claude-code/issues/27968) — `mcpServers` в YAML frontmatter тоже не работает для Task-spawned agents
- v2.1.30 fix затронул только SDK-provided MCP, НЕ plugin MCP

**Workaround:** MCP из global `~/.claude.json` **РАБОТАЕТ** для всех агентов.

**Барьер 2: `tools` allowlist блокирует MCP (НОВОЕ ОТКРЫТИЕ)**

Все три research-агента имеют **explicit `tools` allowlist** в YAML frontmatter:

```yaml
# think-through/agents/expert.md, expert-arena/agents/expert.md, expert-arena/agents/researcher.md
tools:
  - Glob
  - Grep
  - Read
  - WebSearch
  - WebFetch
```

Когда `tools` задан — агент получает **ТОЛЬКО перечисленные tools**. MCP tools (Context7, GitHub Grep) НЕ входят в список → агент их НЕ видит, даже если они есть в global scope.

### Решение: `tools` → `disallowedTools`

Переключиться с allowlist на blocklist:

```yaml
# ВМЕСТО:
tools: [Glob, Grep, Read, WebSearch, WebFetch]

# ТЕПЕРЬ:
disallowedTools: [Edit, Write, Bash, Task, NotebookEdit, ExitPlanMode, EnterPlanMode]
```

**Эффект:** Агент наследует ВСЁ из main conversation (включая MCP tools), кроме заблокированных. Research agents не должны иметь Edit/Write/Bash — они read-only.

### MCP серверы для research

| MCP Server | Scope | Статус | Value для research | Действие |
|---|---|---|---|---|
| **Context7** | Plugin | Подключен, но НЕ доступен subagents | **HIGH** — документация библиотек, code examples | Добавить в global scope |
| **GitHub Grep** | Global | Подключен, доступен | **HIGH** — поиск кода на GitHub | Уже работает |
| **DuckDuckGo** | — | Не подключен | **LOW** — redundant, WebSearch уже есть | Skip |
| **Tavily** | — | Не подключен | **MEDIUM** — AI search, но нужен API key | Phase 2 (optional) |

**Минимальный стек:** Context7 (global) + GitHub Grep (global) + WebSearch/WebFetch (built-in)

### Затронутые агенты и ожидаемый impact

| Агент | Текущие tools | MCP value | Impact |
|---|---|---|---|
| **think-through:expert** | Glob, Grep, Read, WebSearch, WebFetch | Context7 HIGH, GitHub Grep MEDIUM | Эксперты смогут проверять рекомендации по документации, находить production examples |
| **expert-arena:expert** | Glob, Grep, Read, WebSearch, WebFetch | Context7 MEDIUM, GitHub Grep LOW | Дебатёры смогут подкреплять аргументы актуальной документацией |
| **expert-arena:researcher** | Glob, Grep, Read, WebSearch, WebFetch | Context7 HIGH, GitHub Grep HIGH | Основной research agent — максимальный буст от MCP |

### Tool-sniffing pattern (в промпте агента)

```
## MCP Tools (если доступны)

При поиске документации библиотек — проверь доступность Context7:
- Если `mcp__context7__resolve-library-id` в твоих tools → используй Context7 (точнее и быстрее WebSearch)
- Workflow: resolve-library-id → query-docs → получи актуальный код

При поиске code examples на GitHub:
- Если `mcp__github-grep__grep_query` в твоих tools → используй для поиска реальных примеров

Fallback (всегда доступен): WebSearch → WebFetch → inference с [INFERRED] маркером
```

> **Примечание:** Tool names могут отличаться в зависимости от scope (plugin prefix `mcp__plugin_context7_context7__` vs global `mcp__context7__`). Tool-sniffing через "If X is available" решает это.

---

## 2. Архитектура фолбеков

> **Эксперты:** Martin Kleppmann (Distributed Systems), Sam Newman (Architecture)

### Текущие фолбеки (уже есть)

- SIMPLE → MEDIUM escalation (unified-reviewer → specialists)
- STUCK protocol (Lead dispatches researcher)
- Liveness monitoring (Supervisor: ping → nudge → escalate → replacement)
- Deterministic teardown с retry budget

### Чего не хватает (КРИТИЧЕСКИ)

1. **Нет handling для WebSearch/WebFetch failures** — researchers отправляются без fallback инструкций
2. **Нет Bash command retry** — coders запускают build/test через Bash без retry при transient failures
3. **Нет "proceed without" pattern** — когда capability недоступна, агенты либо succeed либо STUCK, ничего между
4. **Нет health summary** — после завершения нет записи какие tools/services были недоступны

### Решение: Двухуровневый fallback

**Уровень 1: Prompt-level (в каждом агенте)**

Добавить "When tools fail" секции:

```
Researchers: если WebSearch пустой → WebFetch на known docs URLs → report "unavailable" с caveat
Coders: если Bash fails → retry once → если опять fails → STUCK с деталями ошибки
Lead: если researcher returns incomplete → proceed with reduced confidence, mark "LIMITED RESEARCH"
```

**Уровень 2: Supervisor-mediated (новый сигнал)**

Новый event: `TOOL_UNAVAILABLE: {tool_name}, agent: {agent_name}, task: {task_id}`

- Вписывается в существующий event contract Supervisor'а
- Lead решает: skip capability / retry with different query / proceed with caveat
- Записывается в state.md для post-mortem

### Чего НЕ берём из AssistAgents

- Model fallback chains (Claude Code контролирует модели)
- Runtime error detection (HTTP 429/503) — handled by Claude Code runtime
- Skill loading priority hierarchy (Claude Code валидирует при install)
- Hook failure isolation (Claude Code manages hooks)

---

## 3. Структура скиллов и агентов

> **Эксперты:** Martin Fowler (Refactoring), Dan Abramov (Colocation)

### Shared Skills: Scoped Fragments (не Universal Baseline)

AssistAgents: universal `base-rules` для всех агентов.
Наш проект: **точечная экстракция** только для реальной дупликации.

**Найденная дупликация в текущем проекте:**
- Self-Verification for CRITICAL Findings — скопировано в 4 reviewers (~40 lines × 4)
- Output format (CRITICAL/MAJOR/MINOR + confidence) — идентичен в 4 reviewers
- "Send findings directly to coder" — в каждом reviewer
- Methodology block (4 verification steps) — структурно идентичен

**Решение:** Создать `references/reviewer-protocol.md` с общим протоколом.

### XML vs Markdown: Оставить как есть

Проект **уже использует XML** где нужно: `<role>`, `<output_rules>`, `<methodology>`, `<example>`. Переход на полный XML — churn без measurable benefit. Anthropic рекомендует XML **селективно**, не как wholesale replacement.

### Из 86 скиллов: взять 1 идею

| Skill Group | Полезно? | Решение |
|-------------|----------|---------|
| testing (12 skills) | **ДА** — добавить test generation к coder workflow | Phase 2 |
| docs (15 skills) | Нет — система самодокументируется через conventions | Skip |
| shared/base-rules | Частично — reviewer-protocol.md | Phase 1 |
| task-use/decomposition | Нет — decomposition встроена в Lead | Skip |
| project/init | Частично — расширить /conventions | Phase 2 |

### Startup Sequence: Lightweight Enhancement

Не полная `startup_sequence` как в AssistAgents, а добавить **Step 0: Orientation** к reviewer agents:

```
1. Read CLAUDE.md (project conventions)
2. Read DECISIONS.md (architectural context)
3. Skim .conventions/ gold-standards relevant to scope
```

Quality-reviewer уже делает это. Security-reviewer и logic-reviewer — **нет**. Это реальный gap.

---

## 4. Уникальные возможности

> **Эксперт:** Sam Newman (Architecture), Kent C. Dodds (Colocation)

### Приоритизированная оценка

| # | Фича | Verdict | Effort | Value | Обоснование |
|---|------|---------|--------|-------|-------------|
| 1 | Init command / project profile | **ADOPT** | Medium | High | Устраняет cold-start; расширение /conventions |
| 2 | Output contracts | **ADOPT** | Low | Medium | Валидация формата ответов researchers |
| 3 | Tool-chains в conventions | **ADOPT** | Low | High | Персистенция build/test/lint команд |
| 4 | Decisions directory | **ADOPT** | Low | Medium | Накопление знаний между sessions |
| 5 | User profiling | **DEFER** | Low-Med | Low | Конфликтует с Full Autonomy дизайном |
| 6 | ai-docs/ tree | **SKIP** | Medium | Negative | Нарушает colocation; текущий подход лучше |
| 7 | Hash-based tools | **SKIP** | N/A | N/A | Невозможно на уровне plugin |
| 8 | Tool gating | **SKIP** | Medium | Low | Instruction-based phasing достаточен |

### Init Command → Расширение /conventions

/conventions уже делает 80% работы. Добавить:
- `.project-profile.yml` — stack, build commands, test commands, key directories
- Subsequent `/team-feature` reads profile → skips codebase-researcher если fresh
- `--fresh` flag для принудительного re-scan

### Conventions expansion

```
.conventions/
├── gold-standards/           # уже есть
├── anti-patterns/            # уже есть
├── checks/                   # уже есть
├── tool-chains/              # НОВОЕ: build/lint/test/typecheck commands
└── decisions/                # НОВОЕ: reusable arch decisions across sessions
```

---

## 5. Промпт-инженерия

> **Эксперт:** Ethan Mollick (Prompt Engineering Research)

### Важное: Claude Code НЕ имеет нативных тегов

Все XML-теги (`<role>`, `<output_rules>`, `<done_criteria>`, `<example>`) — это **prompt engineering для модели Claude**, не нативная разметка Claude Code. Claude Code парсит только:
- **YAML frontmatter** между `---` маркерами
- **`!`command``** — shell preprocessing (выполняется ДО отправки Claude)
- **`$ARGUMENTS`**, `$N` — подстановка аргументов
- **"ultrathink"** в тексте — триггер extended thinking

Поля YAML frontmatter для agents: `name`, `description`, `model`, `tools`, `disallowedTools`, `color`, `mcpServers`, `skills`, `maxTurns`, `permissionMode`, `hooks`, `memory`, `background`, `isolation`.

Нет встроенного поля для done_criteria — реализуем через markdown body.

### 3 техники для внедрения (в формате Claude Code)

#### 1. `<done_criteria>` — explicit completion checklist

Размещение: **после** Communication Protocol table, **перед** `<output_rules>`.
Порядок секций: workflow → done_criteria → decision_policy → output_rules.
Инвариант: **`<output_rules>` всегда закрывает файл** (per gold standard).

Применяется к: **агентам, которые владеют deliverables** (coder, risk-tester).
НЕ применяется к: advisory-only агентам (reviewers, tech-lead) и FSM-агентам (supervisor).

```xml
<done_criteria>
A task is DONE only when ALL of the following are true:
1. Implementation matches gold standard patterns (naming, structure, imports, error handling)
2. All files listed in task description are created/modified -- no extras, no missing
3. Convention self-check (Step 4) passes with zero unfixed items
4. Tool self-check (Step 5) passes: linter clean, types clean, tests pass
5. ALL active roster reviewers + tech-lead have responded
6. ALL CRITICAL and MAJOR findings are fixed
7. ALL Tech Lead feedback is fixed (architecture issues are always blocking)
8. Post-fix self-checks (Step 4 + Step 5) re-pass after any fixes
9. Commit is created with format `feat: <what was done> (task #{id})`
10. Task status is updated to completed via TaskUpdate

A task is NOT DONE if:
- Any reviewer has not responded (unless IMPOSSIBLE_WAIT was sent)
- Any CRITICAL or MAJOR finding remains unfixed
- Any Tech Lead feedback remains unaddressed
- Post-fix self-checks have not been re-run
</done_criteria>
```

#### 2. Priority markers в `<output_rules>`

Маркеры: `[P0]` = violation → immediate escalation, `[P1]` = blocks progress, `[P2]` = best practice.
Группировка: все P0 first, then P1, then P2.

```xml
<output_rules>
[P0] NEVER edit files that belong to another coder's task
[P0] NEVER silently deviate from gold standard — escalate via ESCALATION protocol
[P0] NEVER close a task that fails any <done_criteria> check
[P1] Match gold standard patterns — naming, structure, imports, error handling
[P1] Self-check conventions BEFORE requesting review — prevention > detection
[P1] Send review requests DIRECTLY to reviewers and tech-lead via SendMessage
[P1] When reviewers send feedback, fix CRITICAL and MAJOR. MINOR is optional.
[P1] When tech lead sends feedback, ALWAYS fix — architecture issues are blocking
[P1] Message Supervisor for IN_REVIEW, DONE, STUCK, REVIEW_LOOP, IMPOSSIBLE_WAIT
[P1] Message Lead for QUESTION only
[P1] Message Tech Lead for ESCALATION — architectural decisions
[P2] Don't over-engineer — implement exactly what's needed, nothing more
[P2] Don't refactor code outside your task scope
[P2] If stuck after 2 real attempts, ask for help immediately
[P2] Commit message format: `feat: <what was done> (task #{id})`
</output_rules>
```

#### 3. `<decision_policy>` — routing table

Размещение: **после** `<done_criteria>`, **перед** `<output_rules>`.
Применяется к: агентам с ambiguous judgment calls (coder, tech-lead).
НЕ применяется к: агентам с fixed playbooks (supervisor, reviewers).

```xml
<decision_policy>
## Self-decided (no escalation needed)
- Gold standard pattern fits perfectly -> copy and adapt
- Self-check finds fixable issue -> fix and re-check
- MINOR reviewer feedback -> fix if easy, skip if not
- Next task available after commit -> claim and start

## Escalate to Tech Lead
- Gold standard pattern does not fit the specific case
- Two conflicting gold standards could apply
- Task requires a pattern not covered by any gold standard
- Reviewer feedback contradicts gold standard

## Escalate to Supervisor
- Stuck after 2 real attempts on the same problem
- Review loop: same issue raised 3+ rounds
- Required approver missing from active roster

## Escalate to Lead
- Need information not available in task description or gold standards
- Task description is ambiguous or contradictory
- Scope question: "should I also do X?"
</decision_policy>
```

### Что НЕ берём

- **Full XML restructuring** — risk-reward ratio неправильный, current prompts work
- **Bracket codes `[P0]`, `[B1]` (AssistAgents style)** — используем `[P0]/[P1]/[P2]` (3 уровня vs 10+ у AssistAgents, проще)
- **Placeholder templating `{{var}}`** — SaaS паттерн, Lead строит промпты динамически
- **`<startup_sequence>`** — Step 1 каждого workflow уже это делает
- **`<tool_policy>`** — уже покрыто YAML `tools:` allowlist

---

## План интеграции

### Impact × Effort матрица

**Phase 1 (think-through + MCP) — DONE (2026-02-28):**

| # | Task | Impact | Effort | Файлы | Status |
|---|------|--------|--------|-------|--------|
| 1 | Context7 в global scope | HIGH | 5 min | `~/.claude.json` (user setup) | SKIPPED — Context7 уже в plugin scope, дублирование не требуется. Bug #21560 обойден через disallowedTools |
| 2 | `tools` → `disallowedTools` в 3 agents | HIGH | LOW | expert.md ×2, researcher.md ×1 | DONE — commit `a808e4a` |
| 3 | MCP usage instructions в промптах | MEDIUM | LOW | expert.md ×2, researcher.md ×1 | DONE — commit `a808e4a` |
| 4 | Research methodology в think-through:expert | MEDIUM | LOW | think-through/agents/expert.md | DONE — commit `a808e4a` |
| 5 | Smoke test MCP access | — | 5 min | Ручная проверка | DONE — агент видит 69 MCP tools, Context7 resolve-library-id + query-docs вызваны успешно |

**Phase 2 (deferred):**

| # | Task | Impact | Effort |
|---|------|--------|--------|
| 6 | Web research методология в SKILL.md | HIGH | LOW |
| 7 | Decision trees в SKILL.md | MEDIUM | LOW |
| 8 | Output contracts для researchers | MEDIUM | LOW |
| 9 | `<done_criteria>` + markers в coder.md | MEDIUM | LOW |
| 10 | `reviewer-protocol.md` | MEDIUM | LOW |
| 11 | Gold standard update | LOW | LOW |
| 12+ | Deep improvements (fallbacks, orientation, conventions) | MEDIUM | MEDIUM |

### Phase 1: think-through + MCP (DONE)

#### Task 1: Context7 в global scope

**Действие:** Продублировать Context7 из plugin scope в global, чтобы subagents его видели.

```bash
# Проверить текущий конфиг plugin
cat plugins/think-through/.claude-plugin/plugin.json  # или .mcp.json

# Добавить Context7 в global scope
claude mcp add --scope user context7 -- npx -y @upstash/context7-mcp@latest
```

**Проверка:** GitHub Grep уже в global scope → subagents его видят. Нужно убедиться что Context7 тоже станет доступен.

> **Почему global:** Bug #21560 — plugin MCP не работает для subagents. Global scope — единственный workaround.

---

#### Task 2: Переключить agents с `tools` на `disallowedTools`

**Файлы:**
- `plugins/think-through/agents/expert.md`
- `plugins/expert-arena/agents/expert.md`
- `plugins/expert-arena/agents/researcher.md`

**Изменение YAML frontmatter:**

```yaml
# БЫЛО (allowlist — блокирует MCP):
tools:
  - Glob
  - Grep
  - Read
  - WebSearch
  - WebFetch

# СТАЛО (blocklist — наследует всё кроме опасных, включая MCP):
disallowedTools:
  - Edit
  - Write
  - Bash
  - Task
  - NotebookEdit
  - ExitPlanMode
  - EnterPlanMode
  - EnterWorktree
  - TeamCreate
  - TeamDelete
  - SendMessage
  - TaskCreate
  - TaskGet
  - TaskUpdate
  - TaskList
```

**Почему эти tools в blocklist:**
- `Edit/Write/Bash` — research agents read-only, не должны менять файлы
- `Task/NotebookEdit` — не нужны для research
- `EnterPlanMode/ExitPlanMode/EnterWorktree` — orchestration, не для subagents
- `TeamCreate/TeamDelete/SendMessage/Task*` — team management, не для одиночных research agents

**Что остаётся доступным:** Glob, Grep, Read, WebSearch, WebFetch + ВСЕ MCP tools (Context7, GitHub Grep, и любые будущие)

> **Исключение: expert-arena:expert** — этот агент является членом команды и использует SendMessage, TaskList и т.д. Для него нужен другой blocklist (убрать team tools из blocklist, оставить только Edit/Write/Bash/NotebookEdit).

---

#### Task 3: MCP usage instructions в agent промптах

**Файлы:**
- `plugins/think-through/agents/expert.md` — добавить секцию после "### 1. Project Study"
- `plugins/expert-arena/agents/researcher.md` — добавить в "### 2. Исследуй"
- `plugins/expert-arena/agents/expert.md` — добавить в "## РАБОТА С КОНТЕКСТОМ"

**Добавляемый блок (адаптировать под каждый агент):**

```markdown
### MCP Tools (используй если доступны)

**Документация библиотек:** Если в твоих tools есть `resolve-library-id` или `query-docs`:
1. `resolve-library-id` → получи library ID
2. `query-docs` с конкретным вопросом → получи актуальный код и API

**Code examples на GitHub:** Если в tools есть `grep_query`:
- Ищи production examples: `grep_query(query="[паттерн]", language="[язык]")`
- Фильтруй по repo если знаешь хороший проект

**Fallback (всегда работает):** WebSearch → WebFetch → inference с маркером [INFERRED]

> Не все tools могут быть доступны. Проверяй наличие перед использованием.
```

---

#### Task 4: Улучшить research methodology в think-through:expert

**Файл:** `plugins/think-through/agents/expert.md`

**Текущий workflow (4 шага):**
1. Project Study (Glob/Grep/Read)
2. Expert Analysis (choose experts)
3. Forming Options (2-4 options)
4. Decision

**Новый workflow (5 шагов):**
1. **Project Study** — Glob/Grep/Read (без изменений)
2. **External Research** (NEW) — MCP + WebSearch для актуальных данных
3. **Expert Analysis** — выбор экспертов с учётом найденных данных
4. **Forming Options** — опции подкреплены реальными примерами/docs
5. **Decision** — с confidence level (HIGH/MEDIUM/LOW)

**Ключевые улучшения:**
- Явный шаг для external research ПЕРЕД analysis
- Confidence level в output: HIGH (docs + examples found), MEDIUM (partial data), LOW (mostly inference)
- Source attribution: "[Context7]", "[WebSearch]", "[GitHub Grep]", "[INFERRED]"
- Anti-pattern: "Не давай generic advice — каждая рекомендация должна быть подкреплена источником или явно помечена [INFERRED]"

---

#### Task 5: Verify MCP access (smoke test)

**Действие:** После Tasks 1-4, запустить `/deep-thinking` с аспектом, требующим library documentation.

**Тест-кейс:** "Aspect: Выбор state management для React 19 app. Изучи текущие best practices."

**Ожидаемый результат:**
- Expert agent вызывает `resolve-library-id` для React
- Затем `query-docs` для state management patterns
- В output видим "[Context7]" source attribution

**Если MCP не доступен:**
- Проверить `~/.claude.json` — есть ли context7 в mcpServers
- Проверить что `disallowedTools` не содержит MCP tools
- Fallback: agent использует WebSearch (текущее поведение)

### Phase 2: Остальные улучшения (deferred)

**Из agent-teams (team-feature / coder / reviewers):**
- [x] Web research методология в SKILL.md (general-purpose prompt) — DONE (web-researcher prompt обновлён)
- [x] Decision trees в SKILL.md (5 decision points) — DONE (complexity classification, dispatch matrix)
- [x] Output contracts для codebase-researcher и reference-researcher — DONE (commit `5ced315`)
- [x] `<done_criteria>` + `<decision_policy>` + priority markers в coder.md — DONE (commit `8be8f08`)
- [x] `reviewer-protocol.md` shared reference — DONE (commit `5ced315`)
- [x] Gold standard update (agent-definition.md) — DONE (commit `8849d7e`)

**Deep improvements:**
- [x] Step 2b fallback protocol в team-feature SKILL.md — DONE
- [x] Staged research для COMPLEX features — DONE (Step 2c в SKILL.md)
- [x] Step 0 (orientation) для всех reviewer agents — DONE (commit `cbf5697`)
- [x] `.conventions/tool-chains/` directory — DONE
- [x] `.conventions/decisions/` directory — DONE
- [x] Project profile generation в /conventions skill — DONE (.project-profile.yml)
- [x] `TOOL_UNAVAILABLE` event в Supervisor contract — DONE (playbook #5 + bridge contract)
- [x] Tavily MCP + Exa + DeepWiki + CodeWiki + DuckDuckGo — DONE (добавлены в ~/.claude.json)

---

## Success Metrics

**Phase 1 (think-through + MCP):**

| Metric | Baseline | Target |
|--------|----------|--------|
| MCP tools available to think-through:expert | 0 (blocked by allowlist) | Context7 + GitHub Grep доступны |
| MCP tools available to expert-arena agents | 0 (blocked by allowlist) | Context7 + GitHub Grep доступны |
| Research source diversity | WebSearch only | WebSearch + Context7 + GitHub Grep + WebFetch |
| Source attribution in expert output | None | Every recommendation has [Source] marker |
| Library docs accuracy | WebSearch (may be outdated) | Context7 (up-to-date, code-verified) |

**Phase 2 (deferred):**

| Metric | Baseline | Target |
|--------|----------|--------|
| Research failures handled gracefully | 0% (no fallbacks) | 100% (all failures have defined behavior) |
| Researcher output completeness | ~70% (no contracts) | 95%+ (contract-validated) |
| Coder "when am I done?" clarity | Implicit (workflow order) | Explicit (`<done_criteria>` checklist) |
| Reviewer protocol duplication | ~160 lines across 4 agents | 0 lines (shared reference) |
| Rule priority conflicts | Unresolved (flat list) | Resolved (P0/P1/P2 markers) |
| Decision ambiguity in orchestration | Narrative prose | Structured decision trees |

---

## Что мы НЕ берём (и почему)

| Feature | Почему Skip |
|---------|-------------|
| MCP в plugin `.mcp.json` | Bug #21560 (confirmed OPEN Feb 2026) + #27968. Workaround: global scope |
| `tools` allowlist + MCP | `tools` allowlist блокирует MCP. Решение: `disallowedTools` blocklist |
| `<collect>/<execute>/<verify>/<on_error>` | Текущие patterns + planned `<done_criteria>` достаточны |
| DuckDuckGo MCP | Redundant — WebSearch уже встроен |
| Отдельный web-researcher.md agent | Не нужен — structured prompt в general-purpose достаточен |
| Hash-based file tools | Невозможно на уровне plugin; Claude Code Edit уже достаточен |
| ai-docs/ centralized tree | Нарушает colocation; текущий distributed подход лучше |
| User profiling | Конфликтует с Full Autonomy дизайном agent-teams |
| Full XML prompt migration | Churn без measurable benefit; hybrid уже работает |
| Universal base-rules | Over-engineering; scoped fragments (reviewer-protocol) достаточно |
| Tool gating [G0] | Instruction-based phasing в текущих agents достаточен |
| Model fallback chains | Claude Code контролирует модели, не plugin |
| `<startup_sequence>` | Step 1 каждого workflow уже это делает |
| DeepWiki MCP | Заблокировал scraping — не работает |
| Brave Search MCP | Убрали free tier ($5/month) |

## Claude Code Platform Notes

### YAML Frontmatter (все поля agents)
`name`, `description`, `model`, `tools`, `disallowedTools`, `color`, `mcpServers`, `skills`, `maxTurns`, `permissionMode`, `hooks`, `memory`, `background`, `isolation`

### XML теги — это prompt engineering, не нативная разметка
Claude Code парсит только YAML frontmatter. Все `<role>`, `<output_rules>`, `<done_criteria>` — это инструкции для модели Claude, обрабатываемые как часть промпта.

### Специальный синтаксис в SKILL.md
- `!`command`` — shell preprocessing (выполняется ДО отправки Claude)
- `$ARGUMENTS`, `$0`, `$1` — подстановка аргументов
- "ultrathink" в тексте — триггер extended thinking
- `context: fork` + `agent: Explore` — запуск в forked subagent
