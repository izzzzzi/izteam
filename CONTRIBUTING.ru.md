<p align="right"><a href="./CONTRIBUTING.md">English</a> | <strong>Русский</strong></p>

# Вклад в izteam

Спасибо за интерес к проекту! Это руководство поможет вам начать.

## Начало работы

1. Форкните репозиторий
2. Клонируйте форк:
   ```bash
   git clone https://github.com/<your-username>/izTeam.git
   cd izTeam
   ```
3. Создайте feature-ветку:
   ```bash
   git checkout -b feat/my-feature
   ```

## Структура проекта

```text
izteam/
├── .claude-plugin/       # Манифест marketplace
│   └── marketplace.json
├── plugins/              # Все плагины
│   ├── team/             # /build, /brief, /conventions
│   ├── think/            # /think
│   ├── arena/            # /arena
│   └── audit/            # /audit
├── scripts/              # Скрипты разработки
│   └── bump-version.sh
└── .github/workflows/    # CI/CD
```

Каждый плагин имеет единую структуру:

```text
plugins/<name>/
├── plugin.json           # Манифест плагина (имя, версия, навыки)
├── agents/               # Определения агентов (.md)
├── skills/               # Slash-команды
│   └── <skill>/
│       ├── skill.md      # Промпт навыка
│       └── references/   # Файлы-референсы, загружаемые навыком
├── README.md             # Документация (EN)
└── README.ru.md          # Документация (RU)
```

## Как внести вклад

### Баг-репорты

Создайте issue с:
- Шагами для воспроизведения
- Ожидаемое vs фактическое поведение
- Версия Claude Code и ОС

### Запросы на фичи

Создайте issue с описанием:
- Проблемы, которую вы хотите решить
- Предлагаемого решения
- К какому плагину это относится (или это новый плагин)

### Pull Requests

1. Следуйте [Conventional Commits](https://www.conventionalcommits.org/):
   - `feat:` — новая функциональность
   - `fix:` — исправление бага
   - `docs:` — только документация
   - `chore:` — обслуживание, CI, скрипты
   - `refactor:` — реструктуризация кода без изменения поведения

2. Один логический change на один PR.

3. Обновляйте документацию, если изменение затрагивает пользовательское поведение.

4. Тестируйте изменения плагина локально:
   ```bash
   # Установка из вашей локальной ветки
   /plugin marketplace add <your-username>/izTeam --branch feat/my-feature
   /plugin install <plugin-name>@izteam
   ```

### Создание нового плагина

1. Создайте `plugins/<name>/plugin.json` с обязательными полями:
   ```json
   {
     "name": "<name>",
     "version": "0.1.0",
     "description": "Краткое описание",
     "skills": []
   }
   ```

2. Добавьте плагин в `.claude-plugin/marketplace.json`.

3. Добавьте `README.md` и `README.ru.md` с документацией.

4. Добавьте секцию в корневой `README.md` и `README.ru.md`.

## Версионирование

Версии бампятся автоматически через CI из Conventional Commits.
Для ручного бампа:

```bash
./scripts/bump-version.sh <plugin> patch|minor|major
```

## Кодекс поведения

Проект следует [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md).
