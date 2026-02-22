# ZeroClaw Setup Guide

> Set up your own AI assistant on a €5/month server. Works with WhatsApp, Telegram, Discord, and more.

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**[ZeroClaw GitHub](https://github.com/openagen/zeroclaw)** · **[Report Issue](https://github.com/federicodeponte/openclaw-setup/issues)**

---

## What is ZeroClaw?

<p align="center">
  <img src="assets/whatsapp-real.png" alt="ZeroClaw WhatsApp conversation" width="300">
  <br><sub>Real conversation: ZeroClaw drafting content and saving to GitHub</sub>
</p>

ZeroClaw is an open-source AI assistant written in Rust that runs on your own server. Unlike ChatGPT or Claude, it:

- **Runs 24/7** on a cheap VPS (~€5/month)
- **Uses under 5MB RAM** — single-binary Rust runtime
- **Connects to your apps** via WhatsApp, Telegram, Discord, Slack, Signal, iMessage, and more
- **Remembers context** across conversations (SQLite hybrid search, no external dependencies)
- **29+ AI providers** — Gemini, Anthropic, OpenAI, Mistral, local Ollama models, and more

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
3. **Set environment variables** in your terminal (never paste keys into chat):

```bash
export HETZNER_API_TOKEN="hcloud_xxxxxxxxxxxx"
export ZEROCLAW_API_KEY="your-llm-api-key"
```

4. Open Claude Code or Codex and say:

```
Read https://raw.githubusercontent.com/federicodeponte/openclaw-setup/master/SETUP.md
and set up ZeroClaw for me. Use the credentials already set in $HETZNER_API_TOKEN
and $ZEROCLAW_API_KEY — do not ask me to paste them in chat.
```

5. Scan the WhatsApp QR code when prompted
6. Done — message your assistant on WhatsApp

## What Claude Does vs. What You Do

| Automated by Claude | You Provide |
|---------------------|-------------|
| Creates Hetzner server | Hetzner API token (via env var) |
| Installs ZeroClaw | LLM API key (via env var) |
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

## Migrating from OpenClaw

ZeroClaw includes a built-in migration command:

```bash
zeroclaw migrate openclaw
```

## Available Integrations

**Channels:** WhatsApp, Telegram, Discord, Slack, Mattermost, iMessage, Matrix, Signal, Email, IRC

**AI Providers:** Gemini, Claude, OpenAI, Mistral, local models via Ollama, OpenRouter, and 20+ more

Run `zeroclaw providers` to list all supported providers.

## Setup Guides

| Environment | Guide | Script |
|---|---|---|
| Hetzner VPS (remote, ~€5/mo) | **[SETUP.md](SETUP.md)** | **[setup-hetzner.sh](setup-hetzner.sh)** |
| Mac mini / local server | **[SETUP-MACMINI.md](SETUP-MACMINI.md)** | — |

## FAQ

**Q: Is my data private?**
A: Yes. ZeroClaw runs on YOUR server. API keys are stored encrypted at rest in `~/.zeroclaw/auth-profiles.json`.

**Q: Can I use a different VPS provider?**
A: Yes. Any Ubuntu 24.04 server with 2GB+ RAM works. DigitalOcean, Vultr, AWS, etc.

**Q: What LLMs are supported?**
A: 29+ providers including Gemini, Claude, OpenAI, Mistral, and local models via Ollama.

**Q: How do I add more channels (Telegram, Discord)?**
A: Run `zeroclaw integrations info Telegram` for setup instructions, then configure in `~/.zeroclaw/config.toml`.

## Troubleshooting

See the [Troubleshooting section in SETUP.md](SETUP.md#troubleshooting) or open an [issue](https://github.com/federicodeponte/openclaw-setup/issues).

## Links

- [ZeroClaw GitHub](https://github.com/openagen/zeroclaw)
- [Hetzner Cloud](https://hetzner.cloud)

## Contributing

Issues and PRs welcome. See [SETUP.md](SETUP.md) for the full setup flow.

## License

MIT — see [LICENSE](LICENSE).

---

Made by [@federicodeponte](https://linkedin.com/in/federicodeponte) · Built with [ZeroClaw](https://github.com/openagen/zeroclaw)
