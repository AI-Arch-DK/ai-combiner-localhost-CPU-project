# Performance — Qwen 7B CPU Benchmarks

## Test Hardware

| Parameter | Value |
|---|---|
| CPU | Intel Core i7-8565U @ 1.80GHz (boost 4.6GHz) |
| Cores / Threads | 4c / 8t |
| L3 Cache | 8 MiB |
| RAM | 16 GB (model occupies ~5–6 GB) |
| Model | qwen2.5:7b-instruct-q4_K_M |
| Quantization | Q4_K_M (4-bit mixed) |

## Task Benchmarks (CPU-only)

| qwen_task | max_tokens | ~time | Tokens/sec |
|---|---|---|---|
| qt_002 classify | 10 | ~2 sec | ~5 t/s |
| qt_006 count | 10 | ~2 sec | ~5 t/s |
| qt_003 extract_ip | 100 | ~8 sec | ~13 t/s |
| qt_013 explain_short | 100 | ~8 sec | ~13 t/s |
| qt_012 summarize | 150 | ~12 sec | ~13 t/s |
| qt_021 check_resources | 120 | ~10 sec | ~12 t/s |
| qt_007 mikrotik | 200 | ~16 sec | ~13 t/s |
| qt_015 validate_config | 200 | ~16 sec | ~13 t/s |

## Comparison with HF Cerebras

| Model | Tokens/sec | Cost |
|---|---|---|
| Qwen 7B (local) | ~13 t/s | free |
| Cerebras llama3.1-8b | ~500 t/s | free (rate-limited) |
| Claude Sonnet | fast | $3 / 1M tokens |

## Token Economy Strategy

| Task type | Model | Reason |
|---|---|---|
| Extraction, counting | Qwen local | Fast and free |
| Classification | Qwen local | 10 tokens, ~2 sec |
| Network / research | Cerebras + tavily | Fast inference + up-to-date data |
| bash / sql code | Claude DIRECT | Quality over speed |
| Orchestration | Claude | Reserved for complex tasks only |

## Memory Usage at Runtime

```text
Base system:  ~5 GB
Qwen model:   ~5 GB
Databases:    ~1 GB
Total:        ~11 GB / 16 GB
Swap:         14 GB (reserve)
```
