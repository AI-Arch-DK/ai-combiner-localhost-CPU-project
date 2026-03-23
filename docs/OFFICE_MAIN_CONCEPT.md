# Office_MAIN — концепция мульти-нодового AI-комбайна

## Цель

Расширить однонодовый AI-комбайн (debai localhost) до централизованной сети нод с единой общей БД и центральным оркестратором.

## Топология

```
                    [Office_MAIN-node]
                    центральный оркестратор
                    Claude + Qwen (главный)
                    kombain_shared.db
                           |
              ┌─────────────┬───────────┐
              │            │           │
    [debai-node]   [sales_manager-node]  [другие-nodes]
    localhost CPU   security       ...
    текущая      sales
    kombain         kombain
    _local.db       _local.db
```

## Nodes

| node | Роль | Статус |
|---|---|---|
| **debai** | Рабочая localhost CPU node | ✅ активна |
| **sales_manager** | Security/sales node | ✅ активна |
| **Office_MAIN** | Центральный оркестратор | 🚧 v0.5.0 plan |

## Компоненты Office_MAIN

### Каждая node имеет:
- `kombain_local.db` — локальная БД (workflows, results, knowledge)
- Свой экземпляр Ollama/Qwen
- Набор MCP-серверов под свои задачи

### Общее:
- `kombain_shared.db` (файл `/ai/external/sales_manager/kombain_shared.db`)
- `sync_log` — журнал всех изменений от всех нод

## Протокол синхронизации

```
node выполняет задачу
    │
    ├── Запись в kombain_local.db
    └── INSERT в sync_log (node_id, operation, table_name, payload, status='pending')
              │
              ▼
    Office_MAIN читает sync_log WHERE status='pending'
              │
              ├── Нет конфликта → status='done'
              └── Конфликт → status='conflict' → разрешение вручную
```

## Маршрутизация запросов

```
Запрос на ноду
    │
    ├── Локальная задача → локальный Qwen
    ├── Общая задача → Office_MAIN оркестрирует
    └── Специализация → передаётся спецноде (sales_manager)
```

## Текущее состояние

- `kombain_shared.db` уже создана и доступна через `/ai/external/sales_manager/`
- Схема готова: `db/schemas/kombain_shared_db.sql`
- Реализация синхронизации: план v0.5.0 (issue #4)
