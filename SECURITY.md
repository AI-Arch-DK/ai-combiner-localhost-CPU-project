# Security Policy

## Supported Versions

| Version | Supported |
|---------|:---------:|
| 0.1.x   | ✅        |

## Reporting a Vulnerability

Do **not** open a public GitHub issue for security vulnerabilities.

Please report them privately:

1. Go to **Security → Report a vulnerability** on this repository (GitHub private advisory)
2. Or email the maintainer directly (see GitHub profile)

You will receive a response within **72 hours**.

## Scope

This project runs **locally (localhost, CPU-only)**. External attack surface is minimal.  
However, please report:

- Secrets or API keys accidentally committed
- Unsafe shell command execution paths
- MCP server misconfigurations that could leak data
- Dependency vulnerabilities (pip / npm)

## Out of Scope

- Issues in upstream dependencies (Ollama, Claude Desktop, MCP servers)
- Hardware-level vulnerabilities
