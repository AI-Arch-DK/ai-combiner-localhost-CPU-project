# 🚀 Установка и оптимизация Ollama для CPU-only систем
> Ветка: `dev/ollama-cpu-optimized` | Дата: 2026-04-05
> Протестировано на: Intel i7-8565U, 15.6GB RAM, Debian Forky (kernel 6.19)

---

## 📋 Требования

| Компонент | Минимум | Рекомендуется |
|-----------|---------|---------------|
| RAM | 8GB | 16GB+ |
| CPU | x86_64, AVX2 | i7/i9 8+ потоков |
| Диск | 10GB | 50GB+ NVMe |
| ОС | Linux (Ubuntu/Debian) | Debian 12+ |

```bash
# Проверить AVX2
grep -o "avx[^ ]*" /proc/cpuinfo | sort -u
# Должно быть: avx, avx2
```

---

## 1️⃣ Установка

```bash
curl -fsSL https://ollama.ai/install.sh | sh
curl -s http://localhost:11434/api/version

# Если CLI не подключается:
echo 'export OLLAMA_HOST=http://localhost:11434' >> ~/.bashrc
source ~/.bashrc
ollama list
```

---

## 2️⃣ Модели по объёму RAM

```bash
# 8GB  → ollama pull qwen2.5:3b-instruct-q4_K_M   (2GB, ~16 tok/s)
# 16GB → ollama pull qwen2.5:7b-instruct-q4_K_M   (4.7GB, ~6 tok/s)
# 32GB → ollama pull qwen2.5:14b-instruct-q4_K_M  (9GB, ~3 tok/s)
# 48GB → ollama pull qwen2.5:32b-instruct-q4_K_M  (20GB, ~2 tok/s)
```

---

## 3️⃣ Оптимизация systemd

```bash
sudo mkdir -p /etc/systemd/system/ollama.service.d/

sudo tee /etc/systemd/system/ollama.service.d/optimize.conf << 'EOF'
[Service]
Environment="OLLAMA_NUM_PARALLEL=2"
Environment="OLLAMA_MAX_LOADED_MODELS=1"
Environment="OLLAMA_KEEP_ALIVE=10m"
Environment="OLLAMA_NUM_THREAD=6"
Environment="OLLAMA_FLASH_ATTENTION=1"
OOMScoreAdjust=-500
EOF

sudo systemctl daemon-reload && sudo systemctl restart ollama
```

| RAM | NUM_THREAD | NUM_PARALLEL | MAX_LOADED |
|-----|------------|--------------|------------|
| 8GB | 4 | 1 | 1 |
| 16GB | 6 | 2 | 1 |
| 32GB | 8 | 2 | 2 |
| 48GB | 8 | 3 | 2 |

---

## 4️⃣ RAM ограничение браузеров (cgroup v2)

```bash
# Проверить версию cgroup:
stat -fc %T /sys/fs/cgroup/  # должно быть cgroup2fs

sudo tee /etc/systemd/system/browsers.slice << 'EOF'
[Unit]
Description=Browser slice
Before=slices.target
[Slice]
MemoryMax=1200M
MemoryHigh=900M
EOF

sudo tee /etc/systemd/system/chrome-limit.service << 'EOF'
[Unit]
Description=Limit Chrome memory (cgroup v2)
After=graphical.target
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash -c 'mkdir -p /sys/fs/cgroup/browsers && echo 1258291200 > /sys/fs/cgroup/browsers/memory.max'
[Install]
WantedBy=graphical.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable chrome-limit.service
sudo systemctl start chrome-limit.service
```

> ⚠️ Используем cgroup v2 (`memory.max`), НЕ v1 (`memory.limit_in_bytes`)

---

## 5️⃣ Тест производительности

```bash
curl -s -X POST http://localhost:11434/api/generate \
  -H 'Content-Type: application/json' \
  -d '{"model":"qwen2.5:7b-instruct-q4_K_M","prompt":"Respond in 50 words about AI","stream":false}' \
  | python3 -c "
import json,sys
d=json.load(sys.stdin)
print(f'Speed: {d[\"eval_count\"]/d[\"eval_duration\"]*1e9:.1f} tok/s')
print(f'Time:  {d[\"total_duration\"]/1e9:.1f}s')
"

# Референс:
# i7-8565U 15GB:   ~6.6 tok/s
# i7-1185G7 16GB:  ~8-10 tok/s
# Ryzen 7 5700G:   ~12-15 tok/s
```

---

## ⚠️ Известные проблемы

**iGPU Intel CoffeeLake/WhiskeyLake:**
- OpenCL для LLM НЕ работает (GuC submission N/A)
- Не устанавливайте intel-opencl-icd для LLM inference

**CLI не подключается:**
```bash
export OLLAMA_HOST=http://localhost:11434
```

**Оптимизация Modelfile:**
```bash
ollama show qwen2.5:7b-instruct-q4_K_M --modelfile > /tmp/Modelfile
echo 'PARAMETER num_ctx 4096' >> /tmp/Modelfile
echo 'PARAMETER num_predict 200' >> /tmp/Modelfile
echo 'PARAMETER temperature 0.3' >> /tmp/Modelfile
ollama create qwen-optimized -f /tmp/Modelfile
```

---

## 📊 Референс моделей CPU-only

| Модель | Размер | RAM | tok/s | Назначение |
|--------|--------|-----|-------|------------|
| qwen2.5:3b-q4_K_M | 2GB | 8GB+ | 15-20 | Простые/быстрые |
| qwen2.5:7b-q4_K_M | 4.7GB | 12GB+ | 6-8 | Основная |
| qwen2.5:14b-q4_K_M | 9GB | 20GB+ | 3-4 | Сложные задачи |
| qwen2.5:32b-q4_K_M | 20GB | 36GB+ | 1.5-2 | Исследования |
| llama3.3:70b-q4_K_M | 42GB | 56GB+ | 0.8-1.2 | Максимум качества |