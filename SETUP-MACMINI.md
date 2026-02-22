# ZeroClaw Setup — Mac mini (Local Server)

Run ZeroClaw directly on your Mac mini instead of renting a VPS.
No Hetzner account needed. Your data stays fully local.

**Official docs:** https://github.com/openagen/zeroclaw

---

## What You Need

1. **Mac mini** with macOS 12+ (Apple Silicon or Intel)
2. **LLM API Key** (pick one)
   - **Gemini (free):** https://aistudio.google.com/apikey
   - **Anthropic (best):** https://console.anthropic.com/settings/keys
3. **Homebrew** installed: https://brew.sh

---

## Security Note: How to Pass Credentials

**Never paste API keys into chat messages.** Set environment variables in your terminal before starting Claude Code:

```bash
export ZEROCLAW_API_KEY="your-llm-api-key"
```

---

## Setup Flow

### Step 1: Prevent Sleep

ZeroClaw needs the Mac mini to stay awake 24/7.

```bash
# Disable sleep permanently (run once)
sudo pmset -a sleep 0 disksleep 0

# Verify settings
pmset -g | grep sleep
```

Or via GUI: **System Settings → Energy → Prevent automatic sleeping when the display is off**

### Step 2: Install ZeroClaw

```bash
# Clean install via Homebrew — no curl-pipe-bash
brew install zeroclaw

# Verify
zeroclaw --version
```

### Step 3: Run Onboarding

The interactive wizard prompts for your API key at a password-style input — the value never appears in shell history:

```bash
zeroclaw onboard --interactive
```

When prompted:
- **Provider:** `gemini` (free) or `anthropic` (best)
- **API Key:** paste your key (input is hidden)

Or non-interactively using an environment variable:

```bash
# With Gemini:
zeroclaw onboard --api-key "$ZEROCLAW_API_KEY" --provider gemini

# With Anthropic:
zeroclaw onboard --api-key "$ZEROCLAW_API_KEY" --provider anthropic
```

### Step 4: Install as Background Service

```bash
# Installs a launchd agent — starts automatically on login
zeroclaw service install

# Verify it's running
zeroclaw service status
```

### Step 5: Set Up Network Tunnel

WhatsApp and other channels need to reach your Mac from the internet.
Cloudflare Tunnel is the easiest option — free, no router config, no static IP needed.

```bash
# Install cloudflared
brew install cloudflared

# Authenticate (opens browser)
cloudflared login

# Create a named tunnel
cloudflared tunnel create zeroclaw

# Start the tunnel (routes external HTTPS → local port 3000)
cloudflared tunnel run --url http://localhost:3000 zeroclaw
```

Note the public URL Cloudflare assigns (e.g. `https://zeroclaw.your-subdomain.trycloudflare.com`).
You'll need it when configuring channels.

To run the tunnel automatically on startup:

```bash
# Install as launchd service
sudo cloudflared service install
```

**Alternative — Tailscale** (if you only need access from your own devices):

```bash
brew install tailscale
sudo tailscale up
# Use the Tailscale IP instead of a public tunnel
```

### Step 6: Verify

```bash
zeroclaw status
zeroclaw doctor
```

### Step 7: Connect WhatsApp (Only Manual Step)

```bash
zeroclaw integrations info WhatsApp
```

Follow the output instructions:

1. QR code appears in terminal
2. WhatsApp > Settings > Linked Devices > Link a Device
3. Scan QR code
4. Done

### Step 8: Test

```bash
zeroclaw agent -m "Hello, what can you do?"
```

Send yourself a WhatsApp message to confirm end-to-end.

---

## Migrating from OpenClaw

If you have an existing OpenClaw install:

```bash
zeroclaw migrate openclaw
```

---

## Troubleshooting

**"zeroclaw: command not found" after brew install**
```bash
brew link zeroclaw
# Or add Homebrew to PATH:
eval "$(/opt/homebrew/bin/brew shellenv)"
```

**Service not starting**
```bash
zeroclaw service status
tail -f ~/Library/Logs/zeroclaw/zeroclaw.log
zeroclaw doctor
```

**Mac went to sleep / service stopped**
```bash
# Confirm sleep is disabled
pmset -g | grep sleep

# Restart service
zeroclaw service restart
```

**Channel not receiving messages**
```bash
zeroclaw channel doctor

# Check tunnel is running
cloudflared tunnel info zeroclaw
```

**WhatsApp QR code expired**
```bash
zeroclaw integrations info WhatsApp
# Run the login command again to get a fresh QR code
```

---

## Useful Commands

```bash
zeroclaw doctor              # Full health check
zeroclaw status              # System status
zeroclaw service restart     # Restart daemon
zeroclaw channel doctor      # Channel diagnostics
zeroclaw providers           # List available AI providers
zeroclaw migrate openclaw    # Import from OpenClaw

# Logs (macOS — no journalctl)
tail -f ~/Library/Logs/zeroclaw/zeroclaw.log

# Sleep status
pmset -g | grep sleep
```

---

## Cleanup (Remove Everything)

```bash
# Stop and uninstall service
zeroclaw service uninstall

# Remove zeroclaw binary
brew uninstall zeroclaw

# Remove config and data
rm -rf ~/.zeroclaw

# Remove tunnel
cloudflared tunnel delete zeroclaw
brew uninstall cloudflared

# Re-enable sleep
sudo pmset -a sleep 10 disksleep 10
```

---

## Notes for Claude Code

**Credentials must come from environment variables — never from chat messages:**
```bash
# User sets this in their terminal before starting Claude Code:
export ZEROCLAW_API_KEY="your-api-key"
```

**Automation flow (Mac mini — no SSH, no hcloud):**
```bash
# 1. Prevent sleep
sudo pmset -a sleep 0 disksleep 0

# 2. Install zeroclaw via Homebrew
brew install zeroclaw

# 3. Onboard using env var (key never appears in shell history)
zeroclaw onboard --api-key "$ZEROCLAW_API_KEY" --provider gemini

# 4. Install background service
zeroclaw service install
zeroclaw service status

# 5. Install Cloudflare tunnel
brew install cloudflared
cloudflared login
cloudflared tunnel create zeroclaw
sudo cloudflared service install

# 6. Verify
zeroclaw status
zeroclaw doctor

# 7. WhatsApp (user scans QR)
zeroclaw integrations info WhatsApp
```

**Only manual steps:** Cloudflare browser auth + WhatsApp QR scan
