# 🦞 OpenClaw Setup

Set up your own personal AI assistant in 10 minutes. No coding required.

**Official OpenClaw docs:** https://docs.openclaw.ai

## What You Get

- A personal AI assistant running 24/7
- Message it on WhatsApp, Telegram, Discord, Slack, Signal, iMessage, etc.
- It reads your emails, manages your calendar, remembers your projects
- Costs ~€5/month (Hetzner server)

## Prerequisites

1. **Claude Code** or **Codex** installed
2. A Hetzner Cloud account (or any VPS)
3. An LLM provider (Anthropic recommended, or Gemini free tier)

## Quick Start

1. Open Claude Code or Codex
2. Say:

```
Read github.com/federicodeponte/openclaw-setup/SETUP.md and set up OpenClaw for me on a new Hetzner server
```

3. Follow the wizard prompts
4. Scan the WhatsApp QR code when prompted
5. Done!

## What Happens

1. Creates a Hetzner server (~€5/month)
2. Installs Node.js 22+
3. Installs OpenClaw via npm
4. Runs onboarding wizard: `openclaw onboard --install-daemon`
5. Configures your LLM provider
6. Sets up WhatsApp (you scan QR code)
7. Starts the daemon for 24/7 operation

## Stack

| Component | What | Cost |
|-----------|------|------|
| Server | Hetzner CX22 | ~€5/mo |
| LLM | Anthropic or Gemini | Varies (free tier available) |
| Channels | WhatsApp, Telegram, Discord, etc. | Free |
| Agent | OpenClaw | Free (MIT license) |

## Manual Setup

See [SETUP.md](SETUP.md) for step-by-step instructions.

## Links

- [OpenClaw Docs](https://docs.openclaw.ai)
- [Getting Started](https://docs.openclaw.ai/start/getting-started)
- [OpenClaw GitHub](https://github.com/openclaw/openclaw)
- [Discord](https://discord.gg/clawd)
- [Hetzner Cloud](https://hetzner.cloud)

## Questions?

Open an issue or DM me on [LinkedIn](https://linkedin.com/in/federicodeponte).

---

🦞 *Built with [OpenClaw](https://openclaw.ai)*
