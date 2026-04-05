Night Learning — Overnight Self-Training
Concept

В то время как пользователь оффлайн, система обрабатывает данные, накопленные в сетевой базе, обогащает локальное хранилище qwen_knowledge и актуализирует FAQ-кэш.
Learning Pipeline

Процесс автоматизирован и проходит через следующие этапы:
Plaintext

[02:00 cron]
      |
      ▼
[1] Источник: network.db/templates
    Фильтр: protocol='faq' AND content IS NOT NULL
      |
      ▼
[2] Обработка: Ollama API (модель qwen2.5:7b-instruct-q4_K_M)
    Prompt: "Summarize 3 sentences Russian. Text: {content[:400]}"
    Параметры: num_predict: 120, stream: False
      |
      ▼
[3] Сохранение: kombain_local.db/qwen_knowledge
    Проверка: Skip if source (template_id) already exists
    Data: (topic, subtopic, title, content, source, tags='auto,night,cron', verified=0)
      |
      ▼
[4] Логирование: /data/logs/learning.log
    Запись статусов [start], [ok] {name}, [done] {count} added

Error Handling

Реализована отказоустойчивость для работы в фоновом режиме:

    Проверка доступности: Скрипт обращается к локальному API Ollama (http://localhost:11434).

    Таймауты: Для curl установлен лимит ожидания --max-time 60 (общий timeout 65с), чтобы предотвратить зависание процесса.

    Изоляция сбоев: Весь блок запроса обернут в try...except. Ошибки API или пустые ответы (if resp:) приводят к пропуску записи, а не к остановке скрипта.

    Атомарность: loc.commit() вызывается после каждой успешно обработанной записи.

Cron Configuration

Текущие задачи в crontab -l:
Фрагмент кода

# Ежедневное обучение (02:00)
0 2 * * * python3 /data/scripts/run_night_learning.py >> /ai/logs/learning.log 2>&1

# Еженедельная верификация данных (Воскресенье 03:00)
0 3 * * 0 /data/scripts/night_verify.sh  >> /data/logs/verify.log 2>&1

Maintenance & Verification

Для ручного контроля и отладки используются следующие инструменты:

Просмотр последних логов:
Bash

tail -n 10 /data/logs/learning.log

Проверка объема базы знаний:
Bash

sqlite3 /data/kombain/kombain_local.db "SELECT COUNT(*) FROM qwen_knowledge WHERE tags LIKE '%night%';"

Тестирование доступности модели:
Bash

curl -s http://localhost:11434/api/tags | grep "qwen2.5:7b-instruct-q4_K_M"

Документация актуализирована 05.04.2026 на основе текущей реализации /data/scripts/run_night_learning.py.
