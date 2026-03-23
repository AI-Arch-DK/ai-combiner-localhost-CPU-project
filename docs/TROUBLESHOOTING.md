# Troubleshooting — AI Combiner

## Проблема: скилл перехватывает триггеры системных команд

**Симптом:** "инфо о себе" → скилл `ib-consultant` читает профиль вместо `check_resources.sh`

**Причина:** Скиллы работают до systemPrompt (приоритет №1).

**Решение:** Добавить в `SKILL.md` перед `description`:

```text
НЕ активировать при: "инфо о себе", "проверь ресурсы", "вспомни о себе".

```text

---

## Проблема: shell MCP возвращает `null` на `rm -rf`

**Причина:** shell MCP блокирует опасные команды.

**Решение:** Выполнять вручную в терминале от `debianAI`.

---

## Проблема: Ollama не отвечает

```bash
# Проверка

curl http://localhost:11434/api/tags
systemctl --user status ollama

# Запуск

systemctl --user start ollama

```text

---

## Проблема: qwen_dispatch возвращает `NO_MATCH`

**Причина:** триггер не совпадает ни с одним записями `qwen_tasks`.

**Решение:**

```sql
-- Добавить триггер к существующему таску:
UPDATE qwen_tasks SET trigger = trigger || ',новый триггер'
WHERE task_id = 'qt_XXX';

```text

---

## Проблема: старые skills-plugin папки накапливаются

**Решение:**

```bash
/ai/scripts/cleanup_sessions.sh
# или срабатывает автоматически при "инфо о себе"

```text

---

## Проблема: MCP сервер не подключается

1. Проверь `claude_desktop_config.json` на ошибки JSON
2. Проверь что `node` / `npx` / `uvx` доступны: `which node npx uvx`
3. Перезапустить Claude Desktop
4. Проверить логи: `~/.config/Claude/logs/`
