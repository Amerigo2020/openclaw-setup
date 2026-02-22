# ZeroClaw Setup Instructions

This guide helps Claude Code/Codex set up ZeroClaw on a Hetzner server automatically.

**Official docs:** https://github.com/openagen/zeroclaw

---

## What You Need (Get These First)

1. **Hetzner API Token**
   - Go to https://console.hetzner.cloud
   - Create a project (or use existing)
   - Security > API Tokens > Generate API Token (Read & Write)
   - Copy it

2. **LLM API Key** (pick one)
   - **Gemini (free):** https://aistudio.google.com/apikey
   - **Anthropic (best):** https://console.anthropic.com/settings/keys

3. **SSH Key** (if you don't have one)
   ```bash
   ssh-keygen -t ed25519 -C "zeroclaw"
   cat ~/.ssh/id_ed25519.pub
   ```

---

## Security Note: How to Pass Credentials

**Never paste API keys into chat messages.** Set environment variables in your terminal before starting Claude Code:

```bash
export HETZNER_API_TOKEN="hcloud_xxxxxxxxxxxx"
export ZEROCLAW_API_KEY="your-llm-api-key"
```

Claude Code can then read these from the environment without them appearing in conversation history or logs.

---

## Setup Flow

### Step 1: Install hcloud CLI (Local Machine)

```bash
# macOS
brew install hcloud

# Linux
curl -fsSLO https://github.com/hetznercloud/cli/releases/latest/download/hcloud-linux-amd64.tar.gz
sudo tar -C /usr/local/bin --no-same-owner -xzf hcloud-linux-amd64.tar.gz
rm hcloud-linux-amd64.tar.gz
```

### Step 2: Configure hcloud

```bash
# Create context (paste your API token when prompted)
hcloud context create zeroclaw
```

### Step 3: Upload SSH Key

```bash
# Check if key already exists
hcloud ssh-key list

# If not, create it:
hcloud ssh-key create --name zeroclaw-key --public-key-from-file ~/.ssh/id_ed25519.pub
```

### Step 4: Create Server

```bash
# Check if server already exists
hcloud server list

# If not, create it:
hcloud server create \
  --name zeroclaw \
  --type cpx22 \
  --image ubuntu-24.04 \
  --location nbg1 \
  --ssh-key zeroclaw-key
```

Save the IP address from the output.

### Step 5: SSH Into Server

```bash
# Wait 30s for boot, then verify the host fingerprint via Hetzner before accepting:
hcloud server describe zeroclaw  # shows host fingerprint for verification
ssh root@<SERVER_IP>
```

### Step 6: Install ZeroClaw (On Server)

Download the installer and inspect it before running — never pipe to bash directly:

```bash
apt update && apt upgrade -y

# macOS (local machine): brew install zeroclaw
# Linux server: download, inspect, then run
curl -fsSL https://raw.githubusercontent.com/openagen/zeroclaw/main/scripts/bootstrap.sh \
  -o /tmp/zeroclaw-install.sh

# Read the script before executing it
less /tmp/zeroclaw-install.sh

# Once satisfied, run it
bash /tmp/zeroclaw-install.sh

zeroclaw --version
```

If you prefer to build from source instead (most auditable):

```bash
apt update && apt install -y git curl build-essential
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source ~/.cargo/env
git clone https://github.com/openagen/zeroclaw.git /opt/zeroclaw
cd /opt/zeroclaw
cargo build --release --locked
cp target/release/zeroclaw /usr/local/bin/
```

### Step 7: Run Onboarding

Use the interactive wizard — it prompts for your key at a password-style input so the value never appears in your shell history:

```bash
zeroclaw onboard --interactive
```

Or, if running non-interactively in automation, read the key from an environment variable:

```bash
# With Gemini:
zeroclaw onboard --api-key "$ZEROCLAW_API_KEY" --provider gemini

# With Anthropic:
zeroclaw onboard --api-key "$ZEROCLAW_API_KEY" --provider anthropic
```

Then install the background service:

```bash
zeroclaw service install
```

### Step 8: Verify

```bash
zeroclaw status
zeroclaw doctor
```

### Step 9: Connect WhatsApp (Only Manual Step)

```bash
zeroclaw daemon &
zeroclaw integrations info WhatsApp
```

Follow the integration output to link WhatsApp:

1. QR code appears in terminal
2. WhatsApp > Settings > Linked Devices > Link a Device
3. Scan QR code
4. Done

### Step 10: Test

```bash
zeroclaw agent -m "Hello, what can you do?"
```

---

## Migrating from OpenClaw

If you have an existing OpenClaw install, ZeroClaw includes a one-command migration:

```bash
zeroclaw migrate openclaw
```

---

## Troubleshooting

**"SSH key already exists"**
```bash
hcloud ssh-key list  # Find existing key name
# Use that name in server create, or delete and recreate
```

**"Server name already exists"**
```bash
hcloud server list
hcloud server delete zeroclaw  # If you want to start fresh
```

**"Connection refused" on SSH**
- Wait 60 seconds for server to fully boot
- Check: `hcloud server describe zeroclaw`

**"zeroclaw: command not found"**
```bash
source ~/.bashrc
# Or add to PATH manually:
export PATH="$HOME/.cargo/bin:$PATH"
```

**Service not starting**
```bash
journalctl -u zeroclaw -f  # Check logs
zeroclaw doctor             # Run diagnostics
```

**Channel issues**
```bash
zeroclaw channel doctor
```

---

## Cleanup (Delete Everything)

```bash
# Delete server (stops billing)
hcloud server delete zeroclaw

# Optional: remove SSH key from Hetzner
hcloud ssh-key delete zeroclaw-key

# Optional: remove hcloud context
hcloud context delete zeroclaw
```

---

## Useful Commands

```bash
zeroclaw doctor              # Health check
zeroclaw status              # System status
zeroclaw service restart     # Restart daemon
zeroclaw channel doctor      # Channel diagnostics
journalctl -u zeroclaw -f    # View logs
zeroclaw providers           # List available AI providers
zeroclaw migrate openclaw    # Import from OpenClaw
```

---

## Notes for Claude Code

**Credentials must come from environment variables — never from chat messages:**
```bash
# User sets these in their terminal before starting Claude Code:
export HETZNER_API_TOKEN="hcloud_..."
export ZEROCLAW_API_KEY="your-api-key"
```

**Automation flow:**
```bash
# 1. Setup hcloud
hcloud context create zeroclaw

# 2. Upload SSH key (check first)
hcloud ssh-key list | grep -q zeroclaw-key || \
  hcloud ssh-key create --name zeroclaw-key \
    --public-key-from-file ~/.ssh/id_ed25519.pub

# 3. Create server (check first)
hcloud server list | grep -q zeroclaw || \
  hcloud server create --name zeroclaw --type cpx22 \
    --image ubuntu-24.04 --location nbg1 --ssh-key zeroclaw-key

# 4. Get IP
SERVER_IP=$(hcloud server ip zeroclaw)

# 5. Wait and SSH
sleep 30
ssh root@$SERVER_IP

# 6. On server: download installer, inspect it, then run
curl -fsSL https://raw.githubusercontent.com/openagen/zeroclaw/main/scripts/bootstrap.sh \
  -o /tmp/zeroclaw-install.sh
# Claude should read /tmp/zeroclaw-install.sh before executing
bash /tmp/zeroclaw-install.sh

# 7. Onboard using env var (key never appears in shell history)
zeroclaw onboard --api-key "$ZEROCLAW_API_KEY" --provider gemini
zeroclaw service install

# 8. Verify
zeroclaw status
zeroclaw doctor

# 9. WhatsApp (user scans QR)
zeroclaw daemon &
zeroclaw integrations info WhatsApp
```

**Only manual step:** WhatsApp QR scan
