# DB Relations — схема связей БД

## Схема связей между БД

```text
[routing.db]
  qwen_tasks ──────────────► [kombain_local.db]
  parallel_config            workflow_results.model_used
  routing_log ←──────────────── workflows.task_type

[project.db]                [network.db]
  roadmap.tags ─────────►   templates.protocol='faq'
  actions_log.model_used     configs.device_id → devices
                         └─► [kombain_local.db]
                             qwen_knowledge.source=template_id

[tokens.db]                 [tools.db]
  token_usage.workflow_id    tool_usage.workflow_id
     │                          │
     └─────────────────────────└─► [kombain_local.db]
                                     workflows.workflow_id

[kombain_shared.db] ←──── sync_log ──► [kombain_local.db] (debianAI)
                    ←──── sync_log ──► [kombain_local.db] (sales_manager)

```text

## Seed данные и их связи

| JSON файл | Инициализирует | Ссылается из |
|---|---|---|
| qwen_tasks.json | routing.db/qwen_tasks | parallel_config.task_category |
| parallel_config.json | routing.db/parallel_config | qwen_tasks.category |
| models_seed.json | models.db/models | token_usage.account_id |
| tools_seed.json | tools.db/tools | tool_usage.tool_id |
| token_budget_seed.json | tokens.db/token_accounts | token_usage.account_id |
| model_performance_seed.json | models.db/model_performance | models.model_id |
| compliance_checklist.json | (отдельный документ) | — |

## Порядок инициализации

```bash
# Правильный порядок загрузки seed данных:

# 1. routing.db: qwen_tasks → parallel_config

# 2. models.db: models → model_performance

# 3. tokens.db: token_accounts → token_usage (optional)

# 4. tools.db: tools → tool_usage (optional)

# 5. kombain_local.db: через init_db.sh

```text
