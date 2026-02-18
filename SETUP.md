# OpenClaw Setup Instructions

This file contains the steps to set up OpenClaw on a Hetzner server.
Claude Code or Codex can read and execute these steps automatically.

**Official docs:** https://docs.openclaw.ai/start/getting-started

---

## Step 1: Create Hetzner Server

1. Go to https://console.hetzner.cloud
2. Create new project "openclaw"
3. Add server:
   - Location: Nuremberg (or closest)
   - Image: Ubuntu 24.04
   - Type: CX22 (2 vCPU, 4GB RAM) - ~€5/month
   - SSH key: Add your public key
4. Note the server IP address

## Step 2: SSH Into Server

```bash
ssh root@<SERVER_IP>
```

## Step 3: Install Node.js 22+

OpenClaw requires Node ≥22.

```bash
# Update system
apt update && apt upgrade -y

# Install Node.js 22
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt install -y nodejs

# Verify version
node --version  # Should be v22.x.x
```

## Step 4: Install OpenClaw

```bash
npm install -g openclaw@latest
```

## Step 5: Run Onboarding Wizard

```bash
openclaw onboard --install-daemon
```

The wizard will:
1. Set up the Gateway daemon (systemd service)
2. Ask you to configure your LLM provider
3. Set up channels (WhatsApp, Telegram, etc.)
4. Guide you through authentication

## Step 6: Configure LLM Provider

**Recommended:** Anthropic Pro/Max subscription (best quality)

**Free option:** Google Gemini API
1. Go to https://aistudio.google.com/apikey
2. Create API key
3. Enter when prompted by wizard

## Step 7: Connect WhatsApp

During the wizard, when you enable WhatsApp:

1. A QR code will appear in the terminal
2. Open WhatsApp on your phone
3. Go to Settings > Linked Devices > Link a Device
4. Scan the QR code
5. Done!

## Step 8: Verify Setup

```bash
# Check health
openclaw doctor

# Check version
openclaw --version

# View logs
journalctl -u openclaw -f
```

## Step 9: Send Test Message

```bash
# Via CLI
openclaw agent --message "Hello, what can you do?"

# Or just message yourself on WhatsApp
```

## Useful Commands

```bash
# Run onboarding again
openclaw onboard

# Health check
openclaw doctor

# Update to latest
openclaw update

# Gateway status
systemctl status openclaw
```

## Configuration

Config lives at `~/.openclaw/`:

```
.openclaw/
├── openclaw.json      # Main config
├── agents/            # Your agents
├── credentials/       # API keys (encrypted)
├── memory/            # Agent memory
├── workspace/         # Working files
└── logs/              # Logs
```

## Resources

- **Docs:** https://docs.openclaw.ai
- **Getting Started:** https://docs.openclaw.ai/start/getting-started
- **Channels:** https://docs.openclaw.ai/channels
- **WhatsApp:** https://docs.openclaw.ai/channels/whatsapp
- **Discord:** https://discord.gg/clawd

---

## Notes for Claude Code

When executing these steps:
1. Create Hetzner server (or use user's existing VPS)
2. SSH in and install Node.js 22+
3. Run `npm install -g openclaw@latest`
4. Run `openclaw onboard --install-daemon`
5. Guide user through the wizard prompts
6. Help them get API keys if needed
7. Wait for WhatsApp QR scan
8. Run `openclaw doctor` to verify
