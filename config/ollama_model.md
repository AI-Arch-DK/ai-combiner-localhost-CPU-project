# Ollama Model Config — qwen2.5:7b-instruct-q4_K_M

## Model Parameters

| Parameter | Value |
|---|---|
| Model | qwen2.5:7b-instruct-q4_K_M |
| Family | qwen2 |
| Parameters | 7.6B |
| Quantization | Q4_K_M (4-bit, mixed) |
| File size | 4466 MB (~4.4 GB) |
| Context length | 32,768 tokens |
| Embedding length | 3,584 |
| Layers (blocks) | 28 |
| Attention heads | 28 |
| KV heads | 4 (GQA) |
| Port | 11434 |

## Hardware (debianAI worker node)

| Parameter | Value |
|---|---|
| CPU | Intel Core i7-8565U @ 1.80GHz (boost 4.6GHz) |
| Cores / Threads | 4 cores / 8 threads |
| L3 Cache | 8 MiB |
| RAM | 16 GB (model uses ~5–6 GB) |
| Mode | CPU-only (no GPU) |

## Performance (CPU-only)

| Task | Tokens | Time |
|---|---|---|
| classify (qt_002) | 10 | ~2 sec |
| extract_ip (qt_003) | 100 | ~8 sec |
| explain_short (qt_013) | 100 | ~8 sec |
| summarize (qt_012) | 150 | ~12 sec |
| network_mikrotik (qt_007) | 200 | ~16 sec |
| system_check (qt_021) | 120 | ~10 sec |

## Configuration in claude_desktop_config.json

```json
"ollama-local": {
  "command": "node",
  "args": ["/path/to/ollama-server/server.js"],
  "env": {
    "OLLAMA_HOST": "http://localhost:11434",
    "OLLAMA_MODEL": "qwen2.5:7b-instruct-q4_K_M"
  }
}
```

## Management Commands

```bash
# Service status
systemctl --user status ollama

# List models
curl http://localhost:11434/api/tags

# Quick test
curl http://localhost:11434/api/generate -d '{"model":"qwen2.5:7b-instruct-q4_K_M","prompt":"ping","stream":false}'

# Pull model
ollama pull qwen2.5:7b-instruct-q4_K_M
```

## Token Routing

- `qwen_only` strategies: max_tokens 10–200, timeout 10–60 sec
- `CLAUDE_DIRECT` markers (qt_019, qt_020): Qwen is not called, saving local resources
- Average RAM usage at runtime: +5–6 GB on top of base system load
