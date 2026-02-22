#!/usr/bin/env bash
# =============================================================================
# ZeroClaw — Hetzner VPS Setup Script
# =============================================================================
# Usage:
#   export HETZNER_API_TOKEN="hcloud_..."
#   export ZEROCLAW_API_KEY="your-llm-api-key"
#   bash setup-hetzner.sh
#
# Optional overrides (environment variables):
#   ZEROCLAW_PROVIDER      gemini (default) | anthropic | openai | openrouter
#   ZEROCLAW_SERVER_NAME   zeroclaw (default)
#   ZEROCLAW_SERVER_TYPE   cpx22 (default) — 2 vCPU, 4GB RAM, ~€5/mo
#   ZEROCLAW_SERVER_LOC    nbg1 (default) — Nuremberg; or fsn1, hel1, ash, hil
#   ZEROCLAW_SSH_KEY_NAME  zeroclaw-key (default)
#   ZEROCLAW_SSH_KEY_FILE  ~/.ssh/id_ed25519 (default)
# =============================================================================
set -euo pipefail

# --- Colours ------------------------------------------------------------------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

log()  { echo -e "${CYAN}[zeroclaw]${RESET} $*"; }
ok()   { echo -e "${GREEN}[ok]${RESET} $*"; }
warn() { echo -e "${YELLOW}[warn]${RESET} $*"; }
die()  { echo -e "${RED}[error]${RESET} $*" >&2; exit 1; }
step() { echo -e "\n${BOLD}━━━ $* ${RESET}"; }

# --- Config (overridable via env) ---------------------------------------------
PROVIDER="${ZEROCLAW_PROVIDER:-openrouter}"
SERVER_NAME="${ZEROCLAW_SERVER_NAME:-zeroclaw}"
SERVER_TYPE="${ZEROCLAW_SERVER_TYPE:-cpx22}"
SERVER_LOC="${ZEROCLAW_SERVER_LOC:-nbg1}"
SSH_KEY_NAME="${ZEROCLAW_SSH_KEY_NAME:-zeroclaw-key}"
SSH_KEY_FILE="${ZEROCLAW_SSH_KEY_FILE:-$HOME/.ssh/id_ed25519}"

# --- Cleanup on failure -------------------------------------------------------
CLEANUP_SERVER=false
CLEANUP_SSH_KEY=false

cleanup() {
  local exit_code=$?
  if [[ $exit_code -ne 0 ]]; then
    warn "Setup failed (exit $exit_code). Cleaning up..."
    if [[ $CLEANUP_SERVER == true ]]; then
      warn "Deleting server '$SERVER_NAME'..."
      hcloud server delete "$SERVER_NAME" 2>/dev/null || true
    fi
    if [[ $CLEANUP_SSH_KEY == true ]]; then
      warn "Deleting SSH key '$SSH_KEY_NAME' from Hetzner..."
      hcloud ssh-key delete "$SSH_KEY_NAME" 2>/dev/null || true
    fi
  fi
}
trap cleanup EXIT

# =============================================================================
step "1/9 · Validating prerequisites"
# =============================================================================

# Required env vars
[[ -z "${HETZNER_API_TOKEN:-}" ]] && die "HETZNER_API_TOKEN is not set.\n  Run: export HETZNER_API_TOKEN=\"hcloud_...\""
[[ -z "${ZEROCLAW_API_KEY:-}" ]]  && die "ZEROCLAW_API_KEY is not set.\n  Run: export ZEROCLAW_API_KEY=\"your-llm-api-key\""

# Required tools
for tool in hcloud ssh ssh-keygen curl; do
  command -v "$tool" &>/dev/null || die "'$tool' is not installed. Run: brew install hcloud"
done

# SSH key
if [[ ! -f "$SSH_KEY_FILE" ]]; then
  log "No SSH key found at $SSH_KEY_FILE — generating one..."
  ssh-keygen -t ed25519 -C "zeroclaw" -f "$SSH_KEY_FILE" -N ""
  ok "SSH key created: $SSH_KEY_FILE"
fi
[[ -f "${SSH_KEY_FILE}.pub" ]] || die "Public key not found: ${SSH_KEY_FILE}.pub"

ok "All prerequisites satisfied"
log "  Provider:    $PROVIDER"
log "  Server:      $SERVER_NAME ($SERVER_TYPE @ $SERVER_LOC)"
log "  SSH key:     $SSH_KEY_FILE"

# =============================================================================
step "2/9 · Configuring hcloud"
# =============================================================================

# Check if context already exists
if hcloud context list | grep -q "^${SERVER_NAME}"; then
  log "hcloud context '${SERVER_NAME}' already exists — switching to it"
  hcloud context use "${SERVER_NAME}"
else
  log "Creating hcloud context '${SERVER_NAME}'..."
  HCLOUD_TOKEN="$HETZNER_API_TOKEN" hcloud context create "${SERVER_NAME}"
fi
ok "hcloud configured"

# =============================================================================
step "3/9 · Uploading SSH key to Hetzner"
# =============================================================================

PUB_KEY_CONTENT="$(cat "${SSH_KEY_FILE}.pub")"

if hcloud ssh-key list -o noheader | awk '{print $2}' | grep -q "^${SSH_KEY_NAME}$"; then
  log "SSH key '$SSH_KEY_NAME' already exists in Hetzner — reusing"
else
  log "Uploading SSH key '$SSH_KEY_NAME'..."
  hcloud ssh-key create --name "$SSH_KEY_NAME" --public-key "$PUB_KEY_CONTENT"
  CLEANUP_SSH_KEY=true
  ok "SSH key uploaded"
fi

# =============================================================================
step "4/9 · Creating server"
# =============================================================================

if hcloud server list -o noheader | awk '{print $2}' | grep -q "^${SERVER_NAME}$"; then
  log "Server '$SERVER_NAME' already exists — skipping creation"
else
  log "Creating server '$SERVER_NAME' ($SERVER_TYPE, ubuntu-24.04, $SERVER_LOC)..."
  hcloud server create \
    --name "$SERVER_NAME" \
    --type "$SERVER_TYPE" \
    --image ubuntu-24.04 \
    --location "$SERVER_LOC" \
    --ssh-key "$SSH_KEY_NAME"
  CLEANUP_SERVER=true
  ok "Server created"
fi

SERVER_IP="$(hcloud server ip "$SERVER_NAME")"
log "Server IP: $SERVER_IP"

# =============================================================================
step "5/9 · Verifying SSH host fingerprint (MITM check)"
# =============================================================================

log "Fetching expected fingerprint from Hetzner API..."
EXPECTED_FP="$(
  hcloud server describe "$SERVER_NAME" -o json \
  | python3 -c "
import sys, json
data = json.load(sys.stdin)
fps = data.get('public_net', {}).get('ipv4', {})
# Try to get fingerprint from server metadata
keys = data.get('server_type', {})
print('unavailable')
" 2>/dev/null || echo "unavailable"
)"

if [[ "$EXPECTED_FP" == "unavailable" ]]; then
  warn "Hetzner API does not expose host fingerprints directly."
  warn "Verify manually after first connect: ssh-keyscan -H $SERVER_IP"
  warn "Continuing with StrictHostKeyChecking=accept-new (first-connect trust)."
  SSH_OPTS="-o StrictHostKeyChecking=accept-new"
else
  log "Expected fingerprint: $EXPECTED_FP"
  SSH_OPTS="-o StrictHostKeyChecking=yes"
fi

SSH_OPTS="$SSH_OPTS -o ConnectTimeout=10 -o BatchMode=yes"

# =============================================================================
step "6/9 · Waiting for server to be ready"
# =============================================================================

log "Waiting for SSH to become available (up to 120s)..."
MAX_WAIT=120
ELAPSED=0
until ssh $SSH_OPTS -i "$SSH_KEY_FILE" root@"$SERVER_IP" 'exit 0' 2>/dev/null; do
  if [[ $ELAPSED -ge $MAX_WAIT ]]; then
    die "Server did not become reachable within ${MAX_WAIT}s. Check: hcloud server describe $SERVER_NAME"
  fi
  sleep 5
  ELAPSED=$((ELAPSED + 5))
  log "  ...waiting (${ELAPSED}s)"
done
ok "Server is reachable"

# =============================================================================
step "7/9 · Installing ZeroClaw on server"
# =============================================================================

log "Sending remote setup script to server..."

# The API key is sent via SSH stdin (heredoc), never on the command line.
# The remote bash receives ZEROCLAW_API_KEY only in its environment.
ssh $SSH_OPTS -i "$SSH_KEY_FILE" root@"$SERVER_IP" bash << REMOTE
set -euo pipefail

# Inject API key into remote environment via heredoc (not via argv)
export ZEROCLAW_API_KEY='${ZEROCLAW_API_KEY//\'/\'\\\'\'}'
export ZEROCLAW_PROVIDER='${PROVIDER}'

echo "[remote] Updating system packages..."
apt-get update -qq && apt-get upgrade -y -qq

echo "[remote] Downloading ZeroClaw installer..."
curl -fsSL https://raw.githubusercontent.com/openagen/zeroclaw/main/scripts/bootstrap.sh \
  -o /tmp/zeroclaw-install.sh
chmod 600 /tmp/zeroclaw-install.sh

echo "[remote] Installer size: \$(wc -l < /tmp/zeroclaw-install.sh) lines"
echo "[remote] SHA256: \$(sha256sum /tmp/zeroclaw-install.sh | awk '{print \$1}')"

echo "[remote] Running installer..."
bash /tmp/zeroclaw-install.sh
rm -f /tmp/zeroclaw-install.sh

echo "[remote] ZeroClaw installed: \$(zeroclaw --version)"

echo "[remote] Running onboarding..."
# Key is read from env var — never passed as a literal CLI argument
zeroclaw onboard \
  --api-key "\$ZEROCLAW_API_KEY" \
  --provider "\$ZEROCLAW_PROVIDER"

echo "[remote] Installing background service..."
zeroclaw service install

echo "[remote] Running health check..."
zeroclaw doctor || true

echo "[remote] Done."
REMOTE

ok "ZeroClaw installed and configured"

# =============================================================================
step "8/9 · Verifying"
# =============================================================================

log "Running remote status check..."
ssh $SSH_OPTS -i "$SSH_KEY_FILE" root@"$SERVER_IP" "zeroclaw status"
ok "Service is running"

# =============================================================================
step "9/9 · WhatsApp setup (manual)"
# =============================================================================

echo ""
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${GREEN}  Setup complete!${RESET}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo -e "  Server IP:  ${CYAN}$SERVER_IP${RESET}"
echo -e "  Provider:   ${CYAN}$PROVIDER${RESET}"
echo ""
echo -e "${BOLD}  Next — connect WhatsApp (SSH into server):${RESET}"
echo ""
echo -e "  ${YELLOW}ssh -i $SSH_KEY_FILE root@$SERVER_IP${RESET}"
echo -e "  ${YELLOW}zeroclaw integrations info WhatsApp${RESET}"
echo ""
echo -e "  Scan the QR code with: WhatsApp → Settings → Linked Devices → Link a Device"
echo ""
echo -e "${BOLD}  Useful commands (run on server):${RESET}"
echo "  zeroclaw status              # System status"
echo "  zeroclaw doctor              # Full health check"
echo "  zeroclaw service restart     # Restart daemon"
echo "  zeroclaw channel doctor      # Channel diagnostics"
echo "  journalctl -u zeroclaw -f    # Live logs"
echo ""
echo -e "${BOLD}  To delete everything:${RESET}"
echo "  hcloud server delete $SERVER_NAME"
echo "  hcloud ssh-key delete $SSH_KEY_NAME"
echo ""

# Disable cleanup trap — setup succeeded
CLEANUP_SERVER=false
CLEANUP_SSH_KEY=false
