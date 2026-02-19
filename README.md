# OpenClaw Setup Guide

> Set up your own AI assistant on a €5/month server. Works with WhatsApp, Telegram, Discord, and more.

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**[Official OpenClaw Docs](https://docs.openclaw.ai)** · **[Discord](https://discord.gg/clawd)** · **[Report Issue](https://github.com/federicodeponte/openclaw-setup/issues)**

---

## What is OpenClaw?

<p align="center">
  <img src="assets/whatsapp-demo.png" alt="OpenClaw WhatsApp Demo - Example conversation" width="300">
  <br><sub>Example: Managing GitHub via WhatsApp</sub>
</p>

OpenClaw is an open-source AI assistant that runs on your own server. Unlike ChatGPT or Claude, it:

- **Runs 24/7** on a cheap VPS (~€5/month)
- **Connects to your apps** via WhatsApp, Telegram, Discord, Slack, Signal, iMessage
- **Remembers context** across conversations
- **Extensible** with 49 skills (GitHub, Google Workspace, Home Assistant, etc.)

## What You Get

After following this guide, you'll have:

| Feature | Description |
|---------|-------------|
| AI Assistant | Powered by Gemini (free) or Claude (paid) |
| 24/7 Availability | Runs as a daemon on your server |
| WhatsApp Integration | Message your assistant like a contact |
| Memory | Remembers past conversations |
| Skills | GitHub, coding agents, notes, and more |

## Quick Start

### Prerequisites

1. **[Claude Code](https://github.com/anthropics/claude-code)** or **[Codex](https://openai.com/codex)** installed
2. **[Hetzner Cloud account](https://hetzner.cloud)** (or any VPS)
3. **LLM API key**: [Gemini (free)](https://aistudio.google.com/apikey) or [Anthropic](https://console.anthropic.com)

### One-Command Setup

1. Get your Hetzner API token: console.hetzner.cloud → Security → API Tokens
2. Get your LLM API key (Gemini or Anthropic)
3. Open Claude Code or Codex and say:

```
Read https://raw.githubusercontent.com/federicodeponte/openclaw-setup/master/SETUP.md and set up OpenClaw for me.
Here's my Hetzner API token: <paste>
Here's my Gemini API key: <paste>
```

4. Scan WhatsApp QR code when prompted
5. Done — message your assistant on WhatsApp

## What Claude Does vs. What You Do

| Automated by Claude | You Provide |
|---------------------|-------------|
| Creates Hetzner server | Hetzner API token |
| Installs OpenClaw | LLM API key |
| Configures daemon | — |
| Runs health checks | Scan WhatsApp QR code |

**Only manual step:** Scanning the WhatsApp QR code with your phone.

## Cost Breakdown

| Component | Monthly Cost |
|-----------|--------------|
| Hetzner CPX22 (2 vCPU, 4GB RAM) | ~€5 |
| Gemini API (free tier) | €0 |
| WhatsApp, Telegram, etc. | €0 |
| **Total** | **~€5/month** |

## Available Skills

**Ready immediately (no extra setup):**
- **GitHub** — issues, PRs, repos (requires `gh` CLI auth)
- **Coding agents** — Claude Code, Codex, OpenCode

**Requires CLI installation:**
- **Notes** — Apple Notes, Bear, Obsidian (need respective CLIs)
- **Home automation** — Home Assistant, Eight Sleep
- **Google Workspace** — Gmail, Calendar, Drive (via `gog` CLI)
- **1Password** — secrets management (via `op` CLI)

Run `openclaw skills list` to see all 49 available skills and their status.

## Manual Setup

For step-by-step instructions without Claude Code, see **[SETUP.md](SETUP.md)**.

## FAQ

**Q: Is my data private?**
A: Yes. OpenClaw runs on YOUR server. Your messages, memory, and API keys stay with you.

**Q: Can I use a different VPS provider?**
A: Yes. Any Ubuntu 24.04 server with 2GB+ RAM works. DigitalOcean, Vultr, AWS, etc.

**Q: What LLMs are supported?**
A: Gemini, Claude, OpenAI, Mistral, local models via Ollama, and more.

**Q: How do I add more channels (Telegram, Discord)?**
A: Run `openclaw channels add --channel telegram` and follow the prompts.

## Troubleshooting

See the [Troubleshooting section in SETUP.md](SETUP.md#troubleshooting) or join the [Discord](https://discord.gg/clawd).

## Links

- [OpenClaw Documentation](https://docs.openclaw.ai)
- [OpenClaw GitHub](https://github.com/openclaw/openclaw)
- [Hetzner Cloud](https://hetzner.cloud)
- [Discord Community](https://discord.gg/clawd)

## Contributing

Issues and PRs welcome. See [SETUP.md](SETUP.md) for the full setup flow.

## License

MIT — see [LICENSE](LICENSE).

---

Made by [@federicodeponte](https://linkedin.com/in/federicodeponte) · Built with [OpenClaw](https://openclaw.ai)
