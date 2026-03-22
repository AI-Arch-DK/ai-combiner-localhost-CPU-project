# CATALOG — AI Combiner полный индекс репо

> Быстрая навигация: найди нужный файл за 3 секунды.

---

## 📦 Основные файлы

| Файл | Зачем |
|---|---|
| [README.md](README.md) | Обзор, быстрый старт, железо, MCP |
| [CHANGELOG.md](CHANGELOG.md) | История версий v0.1–v0.3 |
| [VERSION](VERSION) | Текущая версия (0.3.0) |
| [.gitignore](.gitignore) | Блокировка секретов и .db файлов |

---

## 📖 docs/ — документация

### Архитектура
| Файл | Зачем |
|---|---|
| [architecture.md](docs/architecture.md) | Приоритеты слоёв, логика оркестрации |
| [routing_logic.md](docs/routing_logic.md) | ASCII схема + матрица 13 стратегий |
| [DATA_FLOW.md](docs/DATA_FLOW.md) | Потоки данных, токены, запись в БД |
| [SYSTEM_DESCRIPTION.md](docs/SYSTEM_DESCRIPTION.md) | Железо, все MCP, все БД, routing rules |
| [OFFICE_MAIN_CONCEPT.md](docs/OFFICE_MAIN_CONCEPT.md) | Мульти-node, синх через kombain_shared.db |
| [PERFORMANCE.md](docs/PERFORMANCE.md) | Замеры Qwen CPU, сравнение с Cerebras |

### Настройка
| Файл | Зачем |
|---|---|
| [MCP_SETUP.md](docs/MCP_SETUP.md) | Настройка 13 MCP серверов |
| [SKILLS_LIST.md](docs/SKILLS_LIST.md) | 8 скиллов: триггеры, исключения, правила |
| [CONTRIBUTING.md](docs/CONTRIBUTING.md) | Добавить qwen_task / скилл / стратегию |
| [COMMIT_GUIDE.md](docs/COMMIT_GUIDE.md) | Конвенция коммитов |

### Референс
| Файл | Зачем |
|---|---|
| [GLOSSARY.md](docs/GLOSSARY.md) | 25 терминов системы |
| [FAQ.md](docs/FAQ.md) | 8 частых вопросов |
| [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) | 5 частых проблем + решения |
| [QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md) | Шпаргалка: все команды в одном месте |
| [NETWORK_TEMPLATES.md](docs/NETWORK_TEMPLATES.md) | 20 FAQ: MikroTik/cisco/sales |
| [PROJECT_SUMMARY.md](docs/PROJECT_SUMMARY.md) | Итоговый обзор проекта |

### Разработка
| Файл | Зачем |
|---|---|
| [ROADMAP.md](docs/ROADMAP.md) | v0.1–v0.6: что сделано и что планируется |
| [EVALUATION_CRITERIA.md](docs/EVALUATION_CRITERIA.md) | Критерии качества Qwen |
| [TESTING.md](docs/TESTING.md) | Таблица тестов, CI/CD |
| [MONITORING.md](docs/MONITORING.md) | Метрики, пороги, cron |
| [DEPLOYMENT.md](docs/DEPLOYMENT.md) | Деплой + rollback процедура |

### Безопасность
| Файл | Зачем |
|---|---|
| [SECURITY_CHECKLIST.md](docs/SECURITY_CHECKLIST.md) | Правила + команда проверки перед push |
| [DATA_POLICY.md](docs/DATA_POLICY.md) | Что хранится, что передаётся |

---

## 🛠 scripts/ — скрипты

| Скрипт | Зачем | Триггер |
|---|---|---|
| [check_resources.sh](scripts/check_resources.sh) | 7 строк: HOST│DB│MCP│ROUTING│SKILLS│CLEANUP | `инфо о себе` |
| [health_check.sh](scripts/health_check.sh) | OK/WARN/FAIL всех компонентов | вручную / cron |
| [install.sh](scripts/install.sh) | 6 шагов: apt→ollama→model→/ai/→scripts→BD | первая установка |
| [init_db.sh](scripts/init_db.sh) | Инициализация 8 БД из схем | сброс / первая установка |
| [backup_db.sh](scripts/backup_db.sh) | Бэкап всех БД, удаление старше 7 дней | вручную / cron 3:00 |
| [cleanup_sessions.sh](scripts/cleanup_sessions.sh) | Удалить старые skills-plugin сессии | авто из check_resources |
| [audit_security.sh](scripts/audit_security.sh) | Секреты, права, порты, файлы | вручную |
| [test_qwen_tasks.sh](scripts/test_qwen_tasks.sh) | 4 теста Qwen PASS/FAIL | перед деплоем |
| [rotate_logs.sh](scripts/rotate_logs.sh) | Ротация по размеру/возрасту | cron воскресенье |
| [sync_to_shared.sh](scripts/sync_to_shared.sh) | Синх в kombain_shared.db | вручную / v0.5 авто |

---

## 🗄 db/ — базы данных

### schemas/
| Файл | БД | Ключевое |
|---|---|---|
| routing_db.sql | routing.db | qwen_tasks(21) + parallel_config(13) |
| project_db.sql | project.db | goals, roadmap, actions_log+FTS |
| network_db.sql | network.db | devices, configs, templates+FTS |
| tokens_db.sql | tokens.db | accounts, usage, budget |
| tools_db.sql | tools.db | tools(8), tool_usage |
| models_db.sql | models.db | models(5), performance |
| kombain_local_db.sql | kombain_local.db | workflows, results, feedback, knowledge |
| kombain_shared_db.sql | kombain_shared.db | То же + sync_log (мульти-node) |

### data/ — seed данные
| Файл | Содержит |
|---|---|
| qwen_tasks.json | 21 активных таск, промпты, категории |
| parallel_config.json | 13 стратегий маршрутизации |
| models_seed.json | 5 моделей (Qwen/Claude/Cerebras/Tavily) |
| tools_seed.json | 8 инструментов MCP |
| token_budget_seed.json | 4 аккаунта + стратегия local_first |
| model_performance_seed.json | 10 замеров производительности |
| compliance_checklist.json | 14 пунктов, 12/14 выполнено |

---

## ⚙️ config/

| Файл | Зачем |
|---|---|
| [ollama_model.md](config/ollama_model.md) | Параметры qwen2.5:7b + замеры CPU |
| [ai-check-resources.service](config/ai-check-resources.service) | systemd user service автозапуска |
| [environment.example](config/environment.example) | Шаблон переменных (без секретов) |

---

## 🐛 .github/

| Файл | Зачем |
|---|---|
| ISSUE_TEMPLATE/bug_report.md | Шаблон бага |
| ISSUE_TEMPLATE/new_task.md | Шаблон нового qwen_task |
| ISSUE_TEMPLATE/new_skill.md | Шаблон нового скилла |
| pull_request_template.md | Чеклист безопасности перед merge |
| workflows/security_check.yml | CI: блок пуш при нахождении секретов |

---

## 📈 Статистика репо

| Параметр | Значение |
|---|---|
| Всего файлов | ~60 |
| Коммитов | 16 |
| Открытых issues | 3 (v0.4.0 ×2, v0.5.0 ×1) |
| Версия | 0.3.0 |
