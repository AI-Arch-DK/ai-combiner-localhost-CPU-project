# AI Combiner — localhost CPU project

> Local AI orchestrator: Claude Desktop + Qwen/Ollama + 13 MCP. CPU-only, localhost.

[![CI](https://github.com/AI-Arch-DK/ai-combiner-localhost-CPU-project/actions/workflows/ci.yml/badge.svg)](https://github.com/AI-Arch-DK/ai-combiner-localhost-CPU-project/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](CODE_OF_CONDUCT.md)

---

## What is AI Combiner?

**AI Combiner** is a local AI orchestrator that routes tasks between Claude Desktop (conductor), a local Qwen 7B model via Ollama (CPU worker), and external tools/APIs — all on localhost, no GPU required.

- 🧠 **Claude** — orchestrates, codes, reasons
- ⚙️ **Qwen 7B (q4_K_M)** — fast local inference for extraction, classification, translation
- 🔌 **13 MCP servers** — SQLite, filesystem, shell, browser, GitHub, HuggingFace, Tavily, Gmail, GCal, Miro, Clay, and more
- 🗄 **SQLite routing DB** — 28 task rules + 15 parallel strategies

---

## 🚀 Quick Start

```bash
# 1. Install Ollama + model
curl -fsSL https://ollama.ai/install.sh | sh
ollama pull qwen2.5:7b-instruct-q4_K_M

# 2. Create directory structure
mkdir -p /ai/{db,scripts,logs,backup,workspace,external/sales_manager,kombain}

# 3. Init databases
bash scripts/init_db.sh

# 4. Copy scripts
cp scripts/*.sh /ai/scripts/ && chmod +x /ai/scripts/*.sh

# 5. Configure Claude Desktop (see docs/MCP_SETUP.md)
# 6. Launch Claude Desktop
# 7. First message: "about yourself"
```

---

## 🏗 Architecture

```text
User → [SKILLS] → [systemPrompt] → qwen_dispatch → parallel_config → Result
          ↑ intercept   ↑ claude_desktop   ↑ routing.db        ↑ routing.db
```

**Models:** Qwen 7B (local, free) | Claude Sonnet (conductor) | Cerebras llama3.1-8b (external) | Tavily (search)

---

## 📁 Repository Structure

```text
ai-combiner-localhost-CPU-project/
├── README.md
├── CHANGELOG.md
├── SECURITY.md
├── CODEOWNERS
├── .pre-commit-config.yaml
├── config/
│   ├── ollama_model.md
│   └── ai-check-resources.service
├── docs/
│   ├── architecture.md
│   ├── SYSTEM_DESCRIPTION.md
│   ├── routing_logic.md
│   ├── MCP_SETUP.md
│   ├── SKILLS_LIST.md
│   ├── ROADMAP.md
│   ├── CONTRIBUTING.md
│   ├── TROUBLESHOOTING.md
│   ├── FAQ.md
│   └── SECURITY_CHECKLIST.md
├── scripts/
│   ├── check_resources.sh
│   ├── cleanup_sessions.sh
│   ├── init_db.sh
│   ├── backup_db.sh
│   └── health_check.sh
└── db/
    ├── workflows.json
    ├── schemas/
    └── data/
```

---

## 💻 Hardware (reference node)

| CPU | RAM | NVMe | OS | Ollama model |
|---|---|---|---|---|
| i7-8565U 4c/8t 4.6GHz | 16 GB | 954 GB | Debian 6.19.6 | qwen2.5:7b-q4_K_M |

---

## 📡 MCP Servers (13)

`sqlite` `ollama-local` `host-report` `filesystem` `github-pub` `github-priv` `huggingface` `miro` `tavily` `shell` `browser` `clay` `gcal` `gmail`

---

## 🔗 Links

| | |
|---|---|
| 📖 Architecture | [docs/architecture.md](docs/architecture.md) |
| 🔀 Routing logic | [docs/routing_logic.md](docs/routing_logic.md) |
| 📡 MCP Setup | [docs/MCP_SETUP.md](docs/MCP_SETUP.md) |
| 🚧 Roadmap | [docs/ROADMAP.md](docs/ROADMAP.md) |
| ❓ FAQ | [docs/FAQ.md](docs/FAQ.md) |
| 🔧 Troubleshooting | [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) |

---

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](docs/CONTRIBUTING.md) before submitting a PR.

Good first issues are tagged [`good first issue`](https://github.com/AI-Arch-DK/ai-combiner-localhost-CPU-project/labels/good%20first%20issue).

---

## 🛡 Code of Conduct

This project follows the [Contributor Covenant](CODE_OF_CONDUCT.md). Be respectful.

---

## 🔒 Security

See [SECURITY.md](SECURITY.md) for how to report vulnerabilities.

---

## 📜 License

[MIT](LICENSE) © AI-Arch-DK
