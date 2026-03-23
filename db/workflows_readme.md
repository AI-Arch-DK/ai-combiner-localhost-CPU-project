# Workflows — AI Combiner

## Structure

| Field | Description |
|---|---|
| workflow_id | Unique ID |
| task_type | system_check / network_config / system_init |
| name | Human-readable name |
| steps | Execution steps (shell / qwen / hf / tavily) |
| rating | Score 0–5 |
| result | Brief result of the last run |

## system_check Triggers

| Workflow | Trigger | Script |
|---|---|---|
| wf_check_resources | "about yourself" / "check resources" | `/ai/scripts/check_resources.sh` |
| wf_session_cleanup | auto-called from check_resources | `/ai/scripts/cleanup_sessions.sh` |

## qwen_tasks (routing.db)

| ID | Trigger | Category |
|---|---|---|
| qt_021 | about yourself / check resources | system_check |
| qt_022 | clean sessions | system_check |
| qt_001–020 | system / network / code / validation | various |
| qt_029–032 | git push / sync / release / status | git_ops / git_check |

## Updates

After each significant commit, `workflows.json` is updated and pushed to the repository.
