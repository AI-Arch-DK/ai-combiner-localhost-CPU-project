🚀 AI Combiner
Local AI Orchestration Platform (CPU • On-Premise • Enterprise-ready)

Turn your infrastructure into a self-learning engineering system
— not just AI usage, but AI ownership.

[![CI](https://github.com/AI-Arch-DK/ai-combiner-localhost-CPU-project/actions/workflows/ci.yml/badge.svg)](https://github.com/AI-Arch-DK/ai-combiner-localhost-CPU-project/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](CODE_OF_CONDUCT.md)

---

## 🧭 What is AI Combiner?

AI Combiner is a local-first AI orchestration platform that integrates:

# 🧠 Claude (agent / orchestrator)
⚙️ Qwen via Ollama (local CPU inference)
🔌 MCP ecosystem (13+ tools)
🗄 SQLite-based knowledge system

→ into a unified system that executes, validates, and remembers engineering decisions.

| Problem             | Traditional AI         | AI Combiner                 |
| ------------------- | ---------------------- | --------------------------- |
| Data privacy        | ❌ Cloud-dependent      | ✅ Fully local               |
| Knowledge reuse     | ❌ Stateless chats      | ✅ Persistent knowledge base |
| Cost                | ❌ Unpredictable tokens | ✅ Controlled routing        |
| Expertise retention | ❌ Lost                 | ✅ Accumulated               |
| Control             | ❌ Black box            | ✅ Deterministic             |

**AI Combiner** is a local AI orchestrator that routes tasks between Claude Desktop (conductor), a local Qwen 7B model via Ollama (CPU worker), and external tools/APIs — all on localhost, no GPU required
---

## 💡 Business Value

AI Combiner transforms AI from a tool into infrastructure and asset

# 🔗 Full Value Proposition

👉 https://github.com/AI-Arch-DK/ai-combiner-localhost-CPU-project/blob/main/AI%20Combiner%20%E2%80%94%20Value%20Proposition%20and%20Use%20Cases

## 🧠 Executive Summary

AI Combiner is built on four enterprise principles:

1. Control & Governance
Local execution (on-premise)
Deterministic routing
Full audit trail
2. Knowledge as an Asset
Every task → structured artifact
Validated → stored → reusable
Institutional memory grows over time
3. Cost Predictability
Local inference → zero marginal cost
FAQ cache → instant execution
External models → controlled usage
4. AI as Infrastructure
Embedded into DevOps workflows
Not chat — execution layer
Continuously improving system
## 🧬 Digital Twin of Expertise

AI Combiner creates a Digital Twin of your engineering team:

Task → Execution → Validation → Feedback → Knowledge → Reuse

→ enabling:

expertise retention
onboarding acceleration
internal AI agents
monetization potential
## 🚀 Quick Start
# Install Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# Pull model
ollama pull qwen2.5:7b-instruct-q4_K_M

# Setup environment
bash scripts/setup_all.sh

# Launch
Claude Desktop → "about yourself"

## 📖 Full setup: docs/MCP_SETUP.md

## 🏗 Architecture
High-Level Flow
User → Routing → Orchestration → Execution → Validation → Knowledge Base
Detailed Flow
User → [SKILLS] → [systemPrompt] → qwen_dispatch → parallel_config → Result
          ↑ intercept   ↑ claude_desktop   ↑ routing.db        ↑ routing.db
## Core Components
Component	Role
Claude	orchestration, reasoning
Qwen	local execution
MCP servers	tool integration
SQLite DBs	memory & routing
Background worker	knowledge enrichment

## 🛠 Use Cases

# 🖥️ System Admin — Zero-Trust NOC
Log analysis (syslog, dmesg)
Monitoring & automation
→ Reduced MTTR
# 🌐 Network Engineer — Config Engine
Multi-vendor configs
Validation & comparison
→ Fewer errors
# 🔒 Security — Local Pentest Engine
Methodologies & commands
Secure execution
→ Reproducible audits
# 👨‍💻 Developer — Full-Loop Dev
Code generation & review
GitHub integration
→ Faster delivery
# 🎓 Onboarding — AI Mentor
Real cases, not theory
Context-aware answers
→ Faster onboarding
# 🧬 Knowledge Engine
Lifecycle
Task → Result → Validation → Feedback → Storage → Indexing
Storage Layers
Layer	DB
Workflows	kombain_local.db
Templates	network.db
Routing	routing.db
Logs	project.db
Tokens	tokens_db

# 📊 Routing Intelligence
28 task rules (qwen_tasks.json)
15 parallel strategies (parallel_config.json)
Background FAQ generation
Token-aware routing

## 💻 Hardware
Type	Spec
CPU	4c/8t+
RAM	16 GB
Storage	NVMe
OS	Debian/Ubuntu

Scales to 32B models (48GB RAM)

## 📁 Project Structure
.
├── .github/              # CI/CD, templates
├── config/               # env, models, services
├── db/                   # schemas + data
├── docs/                 # full documentation
├── scripts/              # automation & ops
├── skills/               # AI skill definitions
├── AI Combiner — Value Proposition and Use Cases
├── README.md

## 📚 Documentation
Topic	Path
Architecture	docs/architecture.md
Data Flow	docs/DATA_FLOW.md
Security	docs/SECURITY_CHECKLIST.md
MCP Setup	docs/MCP_SETUP.md
Routing	docs/routing_logic.md
FAQ	docs/FAQ.md


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
| i7-8565U 4c/8t 4.6GHz | 16 GB | 256 GB | Debian 6.19.6 | qwen2.5:7b-q4_K_M |

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
Use PR template
Follow commit guide
Add new tasks via ISSUE_TEMPLATE

Contributions are welcome! Please read [CONTRIBUTING.md](docs/CONTRIBUTING.md) before submitting a PR.

Good first issues are tagged [`good first issue`](https://github.com/AI-Arch-DK/ai-combiner-localhost-CPU-project/labels/good%20first%20issue).

---

## 🛡 Code of Conduct
This project follows the [Contributor Covenant](CODE_OF_CONDUCT.md). Be respectful.

---

## 🔐 Security
Local-first execution
Secrets in .env (not logs)
MCP isolation
Pre-flight checks before external calls
See [SECURITY.md](SECURITY.md) for how to report vulnerabilities.

## 📊 Project Maturity
✅ Production-ready architecture
✅ CI/CD + security checks
✅ Modular MCP ecosystem
🚧 Active development

## 🧭 Final Note
AI Combiner is not another AI wrapper.

It is a system that turns engineering knowledge into a scalable, auditable, and ownable asset
---

## 📜 License
[MIT](LICENSE) © AI-Arch-DK
