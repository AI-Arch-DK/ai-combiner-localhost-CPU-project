# Hallucination Guard — Protection Against Hallucinations

## Protection Layers

```text
[Layer 1] Prompt constraints
  → max 50 words in prompt_template
  → "Output X only, no explanation"
  → Specify expected output format

[Layer 2] Task parameters
  → cancel_on_hallucination = 1
  → max_tokens limited
  → max_wait_sec = 30–60

[Layer 3] System detection
  → qwen_dispatch → HALLUCINATION → qwen_cancel
  → Request is rerouted to external tools

[Layer 4] Cross-validation (validate_config)
  → tavily fetches reference documentation
  → Qwen compares its answer against the docs
```

## Hallucination Signals

| Symptom | Action |
|---|---|
| Response > max_tokens × 1.5 | qwen_cancel |
| Repeats the question instead of answering | qwen_cancel |
| Contains non-existent commands or IPs | qwen_cancel |
| Responds in the wrong language | qwen_cancel |

## confidence_score() — Implementation by Category

```python
import re

def confidence_score(response: str, task_category: str) -> float:
    """0.0 = hallucination, 1.0 = reliable answer"""
    r = response.strip()

    if task_category == 'extract_ip':
        ips = re.findall(r'\b(?:\d{1,3}\.){3}\d{1,3}\b', r)
        return 1.0 if ips else 0.0

    if task_category == 'extract_ports':
        ports = re.findall(r'\b\d{1,5}\s*[-—]\s*\w+', r)
        return min(1.0, len(ports) / 3) if ports else 0.0

    if task_category == 'count':
        return 1.0 if r.isdigit() else 0.0

    if task_category == 'classification':
        valid = {'network_config', 'code_generation', 'system_check',
                 'database', 'orchestration', 'simple_query'}
        return 1.0 if r.lower() in valid else 0.0

    if task_category == 'translate':
        return 0.8 if len(r) > 5 else 0.0

    if task_category in ('summarize', 'explain_short'):
        sentences = r.count('.') + r.count('!')
        return 1.0 if 2 <= sentences <= 6 else 0.5

    if task_category in ('network_mikrotik', 'network_cisco'):
        return 1.0 if '/' in r else 0.3

    return 0.7  # default for other categories

# Usage:
# score = confidence_score(qwen_response, task.category)
# if score < 0.5: qwen_cancel(query_id, reason='hallucination')
```

## Related Tasks

- `qt_015` (validate_config) — cross-validation via tavily
- `qt_018` (fact_check) — contradiction detection
- `qt_023` (security check) — pre-push validation
