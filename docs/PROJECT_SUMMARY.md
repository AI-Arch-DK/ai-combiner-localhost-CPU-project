# Project Summary — AI Combiner

## Что это

**AI Combiner** — локальный AI-оркестратор на базе **Claude Desktop** + **Qwen 7B (Ollama)** + **13 MCP-серверов**. Работает целиком на CPU, без GPU.

## Цифры

| Параметр | Значение |
|---|---|
| Модель | qwen2.5:7b-instruct-q4_K_M |
| Размер модели | 4.4 GB |
| Context | 32 768 токенов |
| CPU | i7-8565U 4c/8t, буст 4.6 GHz |
| RAM | 16 GB |
| БД | 7 локальных + 1 shared |
| qwen_tasks | 21 активных задач |
| parallel_config | 13 стратегий |
| Скиллы | 8 |
| Файлов в репо | 55+ |

## Ключевые компоненты

```text
Claude Desktop  →  дирижёр/оркестратор
Qwen 7B (local) →  воркер (бесплатно)
Cerebras llama  →  быстрый внешний inference
Tavily / browser → актуальные данные
routing.db      →  правила маршрутизации

```text

## Стратегия экономии токенов

```text
Типовые задачи → Qwen (local, free)
Исследования    → Cerebras (serverless, free)
bash/sql код  → Claude DIRECT (quality > speed)
Оркестрация   → Claude (only complex tasks)

```text

## Версия

`v0.3.0` (2026-03-19) — см. [CHANGELOG.md](../CHANGELOG.md) и [ROADMAP.md](ROADMAP.md)

## Репозиторий

`github.com/GitHub public account/ai-combiner-localhost-CPU-project`
