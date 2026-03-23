# FAQ — AI Combiner

## Что такое AI-комбайн?

Оркестратор, который автоматически распределяет запросы между локальной LLM (Qwen), облачными API и инструментами MCP. Claude Desktop — дирижёр, Qwen — воркер.

---

## Почему Qwen, а не Claude для всего?

Qwen работает локально бесплатно, экономия Claude-токенов. Стратегия: типовые задачи (извлечь, переведи, подсчитай) → Qwen. Комплексные (оркестрация, код) → Claude.

---

## Сколько времени отвечает Qwen?

| Задача | max_tokens | Время CPU |
|---|---|---|
| classify | 10 | ~2 сек |
| extract | 100 | ~8 сек |
| summarize | 150 | ~12 сек |
| network config | 200 | ~16 сек |

---

## Как запустить проверку системы?

Первое сообщение в чате: **"инфо о себе"** → запускается `check_resources.sh` → 7 строк состояния.

---

## Как добавить новую задачу в Qwen?

```sql
INSERT INTO qwen_tasks VALUES ('qt_NNN', 'триггер', 'category',
  'Short prompt. Output only.', 200, 1, 'описание', 0, 1, 60);

```text
См. `docs/CONTRIBUTING.md`

---

## Как создать бэкап БД?

```bash
bash /ai/scripts/backup_db.sh
# Бэкапы сохраняются в /ai/backup/YYYYMMDD_HHMMSS/

# Авто-удаление старше 7 дней

```text

---

## Как добавить новый скилл?

См. `docs/CONTRIBUTING.md` — раздел "Добавить новый скилл".

---

## Что такое Office_MAIN?

Концепция большой мульти-нодовой сети: центральная node (Office_MAIN) + периферийные (debianAI, sales_manager и др.). Синхронизация через `kombain_shared.db`. Статус: v0.5.0 plan.

---

## Что публиковать, а что нет?

| Можно ✅ | Нельзя ❌ |
|---|---|
| SQL схемы | .db файлы |
| Скрипты | claude_desktop_config.json |
| Документация | config.env |
| workflows JSON | API ключи |
