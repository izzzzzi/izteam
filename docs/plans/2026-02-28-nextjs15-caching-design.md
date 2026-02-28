# Next.js 15 — Новая модель кэширования

> **Status:** Research complete
> **Date:** 2026-02-28
> **Goal:** Разобраться в изменениях кэширования Next.js 15, стратегиях миграции с v14 и новых API

---

## Table of Contents

1. [Overview](#overview)
2. [fetch() — смена дефолта](#1-fetch--смена-дефолта)
3. [Route Handlers (GET)](#2-route-handlers-get)
4. [Client Router Cache](#3-client-router-cache)
5. [`use cache` directive](#4-use-cache-directive)
6. [Partial Prerendering (PPR)](#5-partial-prerendering-ppr)
7. [Стратегия миграции с v14](#6-стратегия-миграции-с-v14)
8. [Implementation Plan](#implementation-plan)

---

## Overview

### Философия изменений

Next.js 15 совершил **фундаментальный сдвиг** в философии кэширования: от **opt-out** (всё кэшируется, отключай вручную) к **opt-in** (ничего не кэшируется, включай явно). Причина — неявное кэширование в v14 создавало три класса проблем: непредсказуемое поведение, уязвимости безопасности и невоспроизводимые баги.

### Key Decisions

| Аспект | Решение |
|--------|---------|
| fetch() | `no-store` по умолчанию; кэш через `cache: 'force-cache'` |
| Route Handlers GET | Не кэшируются; кэш через `dynamic: 'force-static'` или `use cache` |
| Client Router Cache | `staleTime: 0` для динамических страниц; настройка через `staleTimes` |
| Новый API кэширования | `'use cache'` directive заменяет `unstable_cache` |
| PPR | Гибридный рендеринг: static shell + dynamic holes через Suspense |
| Миграция | Strangler Fig — постепенно, по слоям, с compatibility flags |

---

## 1. fetch() — смена дефолта

> **Experts:** Theo Browne, Martin Fowler, Troy Hunt

### Что изменилось

| Параметр | v14 | v15 |
|----------|-----|-----|
| Дефолт fetch() | `cache: 'force-cache'` | `cache: 'no-store'` |
| Безопасность | Может кэшировать авторизованные запросы | Свежие данные всегда |
| Предсказуемость | Низкая (неявное поведение) | Высокая (кэш виден в коде) |

### Как работает в v15

```typescript
export default async function RootLayout() {
  const a = await fetch('https://...') // НЕ кэшируется (v15 дефолт)
  const b = await fetch('https://...', { cache: 'force-cache' }) // Кэшируется
  const c = await fetch('https://...', { next: { revalidate: 3600 } }) // ISR: 1 час
}
```

### Глобальный opt-in через fetchCache

```typescript
// Все fetch в этом layout/page кэшируются по умолчанию
export const fetchCache = 'default-cache'

export default async function MarketingLayout({ children }) {
  const nav = await fetch('/api/nav')       // Cached
  const hero = await fetch('/api/hero')     // Cached
  return <div>{children}</div>
}
```

### Матрица решений для каждого fetch

```
Вопрос 1: Данные одинаковы для всех пользователей?
  НЕТ → НЕ кэшировать (дефолт v15)
  ДА  → Вопрос 2

Вопрос 2: Данные меняются чаще чем раз в минуту?
  ДА  → НЕ кэшировать (или revalidate: 60)
  НЕТ → cache: 'force-cache' + next: { revalidate: N }
```

---

## 2. Route Handlers (GET)

> **Experts:** Sam Newman, Theo Browne, Martin Kleppmann

### Что изменилось

GET Route Handlers **больше не кэшируются** по умолчанию. В v14 они были статическими.

### Три стратегии кэширования Route Handlers

**A: `force-static` — весь handler статический**

```typescript
export const dynamic = 'force-static'
export const revalidate = 3600 // ISR

export async function GET() {
  const config = await getAppConfig()
  return Response.json(config)
}
```

**B: `use cache` — гранулярный кэш внутри handler**

```typescript
import { cacheLife, cacheTag } from 'next/cache'

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url)
  const category = searchParams.get('category')
  const products = await getProducts(category) // кэшируется внутри
  return Response.json(products)
}

async function getProducts(category: string | null) {
  'use cache'
  cacheLife('hours')
  cacheTag(`products-${category}`)
  return await db.query('SELECT * FROM products WHERE category = $1', [category])
}
```

**C: HTTP Cache-Control — стандартный веб-подход**

```typescript
export async function GET() {
  const data = await db.query('SELECT * FROM products')
  return Response.json(data, {
    headers: {
      'Cache-Control': 'public, max-age=3600, stale-while-revalidate=86400',
    },
  })
}
```

### Рекомендация по типу данных

| Тип данных | Подход | Почему |
|------------|--------|--------|
| Пользовательские | Без кэша (дефолт) | Уникальны per-user |
| Публичные справочные | HTTP Cache-Control | CDN кэш масштабируется |
| Агрегированные дорогие | `use cache` | Server-side кэш запросов |
| Статические конфиги | `force-static` | Build-time, максимум скорости |

---

## 3. Client Router Cache

> **Experts:** Dan Abramov, Nir Eyal, Theo Browne

### Что изменилось

| Параметр | v14 | v15 |
|----------|-----|-----|
| staleTime (dynamic pages) | 30 секунд | **0 секунд** |
| staleTime (static pages) | 5 минут | 5 минут |

### Проблема v14

```
1. Пользователь открывает /orders — видит 5 заказов
2. Создаёт новый заказ (6-й)
3. Переходит на /profile и обратно на /orders
4. Видит 5 заказов (из 30-сек кэша) — 6-й "пропал"
```

### Настройка в v15

```javascript
// next.config.js
const nextConfig = {
  experimental: {
    staleTimes: {
      dynamic: 0,    // дефолт v15 — свежие данные всегда
      static: 300,   // 5 минут для статических страниц
    },
  },
}
```

### Best Practice: loading.tsx вместо stale данных

```
/app/orders/
  page.tsx        ← динамические данные, всегда свежие
  loading.tsx     ← скелетон на время запроса (честный UX)
  error.tsx       ← обработка ошибок
```

> **Принцип Dan Abramov:** "Мгновенная навигация с устаревшими данными — это молчаливая ложь. Loading state честнее."

---

## 4. `use cache` directive

> **Experts:** Matt Pocock, Dan Abramov, Martin Fowler

### Сравнение с unstable_cache

| Критерий | `unstable_cache` (v14) | `'use cache'` (v15) |
|----------|------------------------|---------------------|
| Ключ кэша | Ручной массив строк | Автоматически из аргументов |
| Область | Только функции | Функции + компоненты + файлы |
| Теги | Вне функции (в options) | Внутри через `cacheTag()` |
| Активация | Всегда | Требует `dynamicIO: true` |

### Профили кэширования (cacheLife)

```typescript
// Встроенные профили
cacheLife('seconds')   // stale: 0,     revalidate: 1,     expire: 60
cacheLife('minutes')   // stale: 60,    revalidate: 60,    expire: 3600
cacheLife('hours')     // stale: 3600,  revalidate: 3600,  expire: 86400
cacheLife('days')      // stale: 86400, revalidate: 86400, expire: 604800
cacheLife('weeks')     // stale: 604800, revalidate: 604800, expire: 2592000
cacheLife('max')       // максимальные значения
```

### Кастомные профили

```typescript
// next.config.ts
const nextConfig: NextConfig = {
  experimental: {
    dynamicIO: true,
    cacheLife: {
      blog: {
        stale: 60 * 60 * 24,      // 1 день на клиенте
        revalidate: 60 * 60,      // 1 час на сервере
        expire: 60 * 60 * 24 * 7, // максимум 7 дней
      },
      exchange: {
        stale: 0,
        revalidate: 60 * 15,      // 15 минут
        expire: 60 * 60,
      },
    },
  },
}
```

### Три уровня применения

**Уровень 1: Функция (data layer) — рекомендуемый**

```typescript
async function getProduct(id: string) {
  'use cache'
  cacheTag(`product-${id}`, 'products')
  cacheLife('hours')
  return await db.products.findUnique({ where: { id } })
}
```

**Уровень 2: Компонент**

```typescript
async function ProductList({ category }: { category: string }) {
  'use cache'
  cacheTag(`category-${category}`)
  cacheLife('minutes')
  const products = await db.products.findMany({ where: { category } })
  return <ul>{products.map(p => <li key={p.id}>{p.name}</li>)}</ul>
}
```

**Уровень 3: Страница (грубый)**

```typescript
export default async function BlogPage({ params }: { params: { slug: string } }) {
  'use cache'
  cacheTag(`post-${params.slug}`)
  cacheLife('blog')
  const post = await getPost(params.slug)
  return <article>{post.content}</article>
}
```

### Type-safe теги (рекомендация Matt Pocock)

```typescript
// lib/cache-tags.ts — единый источник истины
export const CacheTags = {
  products: {
    all: 'products' as const,
    byId: (id: string) => `product-${id}` as const,
    byCategory: (cat: string) => `category-${cat}` as const,
  },
  posts: {
    all: 'posts' as const,
    bySlug: (slug: string) => `post-${slug}` as const,
  },
} as const
```

### Ограничения сериализации

```typescript
// МОЖНО передавать как аргументы:
// string, number, boolean, null, undefined, Date, URL, plain objects, массивы

// НЕЛЬЗЯ передавать:
// class instances, Function, Symbol, Map, Set, JSX.Element (как аргументы)

// ОПАСНО — значения фиксируются навсегда:
export default async function Page() {
  'use cache'
  const random = Math.random()       // всегда одно число!
  const now = Date.now()             // всегда одна дата!
}
```

---

## 5. Partial Prerendering (PPR)

> **Experts:** Martin Kleppmann, Dan Abramov, Sam Newman

### Как работает

PPR комбинирует статическую оболочку (shell) с динамическими компонентами (holes):

```
BUILD TIME:
┌─────────────────────────────────┐
│  <Header />          ← статика  │
│  <h1>Catalog</h1>    ← статика  │
│  ┌─────────────────┐            │
│  │ <Suspense>      │ ← дыра     │
│  │  fallback: skel │ ← в shell  │
│  │  <UserCart />   │ ← стрим    │
│  └─────────────────┘            │
│  <Footer />          ← статика  │
└─────────────────────────────────┘

REQUEST TIME:
→ CDN: статический shell (мгновенно, ~5-30ms TTFB)
→ Origin: параллельный запуск динамики
→ Stream: chunks с динамическим контентом
→ Client: React замена fallbacks
```

### Suspense — единственный механизм объявления дыр

```tsx
export const experimental_ppr = true

export default function Page() {
  return (
    <section>
      <h1>Prerendered</h1>                       {/* static shell */}
      <Suspense fallback={<AvatarSkeleton />}>    {/* hole boundary */}
        <User />                                  {/* dynamic hole */}
      </Suspense>
    </section>
  )
}
```

### Три состояния компонента в PPR

| Состояние | Описание | Пример |
|-----------|----------|--------|
| Статический | Запекается навсегда | `<Header />`, `<Footer />` |
| Кэшированный | В shell с TTL (`use cache`) | `<ProductList />` с `cacheLife('hours')` |
| Динамическая дыра | Стримится при каждом запросе | `<UserCart />` (читает cookies) |

### Влияние на метрики

| Метрика | SSR | SSG | PPR |
|---------|-----|-----|-----|
| TTFB | Высокий | Низкий | **Низкий** |
| FCP | Средний | Низкий | **Низкий** |
| LCP | Средний | Низкий | Зависит от позиции LCP-элемента |
| CLS | Низкий | Низкий | **Требует внимания** (fallback размеры!) |

### Когда PPR оправдан

- E-commerce: каталог (статика) + корзина (динамика)
- Dashboard: каркас (статика) + метрики (динамика)
- Документация: контент (статика) + поиск (динамика)

### Когда НЕ оправдан

- Полностью персонализированные страницы (90% — дыры)
- Real-time данные (WebSocket/SSE)
- Страницы с динамическими og:image в `<head>`

---

## 6. Стратегия миграции с v14

> **Experts:** Martin Fowler, Kent C. Dodds, Theo Browne

### Strangler Fig — рекомендуемый подход

#### Фаза 0: Аудит (1-2 дня)

```bash
# Все fetch без явного cache
grep -rn "fetch(" ./app ./src --include="*.ts" --include="*.tsx" | grep -v "cache:"

# Все GET Route Handlers
find ./app -name "route.ts" -o -name "route.tsx" | xargs grep -l "export async function GET"

# Все unstable_cache
grep -rn "unstable_cache" ./app ./src --include="*.ts" --include="*.tsx"
```

#### Фаза 1: Страховочная сетка (1 день)

```typescript
// next.config.ts — сохраняем поведение v14
const nextConfig = {
  experimental: {
    staleTimes: { dynamic: 30, static: 180 },
  },
}

// app/layout.tsx
export const fetchCache = 'default-cache'
```

Деплоим. Поведение идентично v14.

#### Фаза 2: Миграция fetch (1-2 спринта)

По одному сегменту: убираем `fetchCache`, проставляем `cache` явно каждому fetch.

```typescript
// До (v14 — неявно кэшировалось)
const posts = await fetch('https://api.example.com/posts')

// После (v15 — явно)
const posts = await fetch('https://api.example.com/posts', {
  next: { revalidate: 3600, tags: ['posts'] },
})
```

#### Фаза 3: Route Handlers (параллельно с фазой 2)

Добавляем `force-static` только к handler-ам с публичными статическими данными.

#### Фаза 4: unstable_cache → use cache (2-4 недели, без спешки)

```typescript
// Было
const getCachedUser = unstable_cache(
  async (id) => db.users.findById(id),
  ['user'],
  { revalidate: 60, tags: ['users'] }
)

// Стало
async function getUser(id: string) {
  'use cache'
  cacheTag(`user-${id}`)
  cacheLife('minutes')
  return db.users.findById(id)
}
```

### Риски миграции

1. **Тихая регрессия производительности** — fetch без явного `cache` начнут ходить в сеть при каждом рендере
2. **Двойная инвалидация** — `revalidateTag` + `staleTime: 0` = всегда свежие данные (это нормально, но неожиданно)
3. **Конфликт fetchCache** — parent layout `default-cache` + child page `force-no-store` = ошибка в v15
4. **`use cache` ещё experimental** — API может измениться; `dynamicIO: true` обязателен

---

## Implementation Plan

### Phase 1: Безопасный апгрейд

- [ ] Запустить `npx @next/codemod@canary upgrade latest`
- [ ] Добавить compatibility flags (`fetchCache`, `staleTimes`)
- [ ] Убедиться что тесты проходят, деплой работает
- [ ] Добавить мониторинг внешних API (cache miss rate)

### Phase 2: Постепенная миграция

- [ ] Аудит всех fetch-вызовов (grep-скрипты)
- [ ] Классификация: статичные / динамичные / пользовательские
- [ ] Миграция по сегментам (1 domain/неделю)
- [ ] Route Handlers: добавить `force-static` где нужно
- [ ] Убрать `fetchCache = 'default-cache'` из root layout

### Phase 3: Новые возможности

- [ ] Внедрить `use cache` для новых фич
- [ ] Создать type-safe CacheTags объект
- [ ] Настроить кастомные cacheLife профили
- [ ] Рассмотреть PPR для подходящих страниц

---

## Success Metrics

| Metric | Baseline (v14) | Target (v15) |
|--------|----------------|--------------|
| Stale data bugs | Периодические | 0 |
| Explicit cache annotations | 0% | 100% fetch-вызовов |
| TTFB (статические страницы) | ~50ms | ~50ms (без регрессии) |
| External API requests | baseline | +0% после миграции |
| `unstable_cache` usage | N calls | 0 (заменены на `use cache`) |

---

## Sources

- [Next.js 15 Upgrade Guide](https://nextjs.org/docs/app/guides/upgrading/version-15)
- [Next.js Caching Guide](https://nextjs.org/docs/app/guides/caching)
- [use cache Directive](https://nextjs.org/docs/app/api-reference/directives/use-cache)
- [Route Handlers](https://nextjs.org/docs/app/getting-started/route-handlers)
- Context7: `/vercel/next.js` v15.1.8, `/websites/nextjs`
