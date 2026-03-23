#!/bin/bash
# =============================================================================
# ACME IT Corp - Tripwire File Integrity Monitoring
# =============================================================================
# Installs Tripwire, generates site/local keys, signs the config and policy,
# and initializes the baseline database. Any file changes after this point
# will be detected on the next integrity check.
#
# Run independently:  sudo ./defenses/tripwire.sh
# Called by:          setup.sh
#
# ⚠️  IMPORTANT: Run this LAST — after all other setup scripts have completed.
#     If you initialize the baseline before other modules run, you will get
#     large numbers of false-positive alerts for expected changes.
#     See defenses/README.md for the recommended deployment order.
#
# Run a check:    sudo tripwire --check
# View report:    sudo twprint --print-report -r <report-file>
# Update baseline after intentional changes:
#                 sudo tripwire --update --twrfile <report-file>
# =============================================================================

set -euo pipefail

echo "[tripwire] Installing Tripwire..."

# Pre-seed debconf so apt doesn't prompt for passphrases interactively
debconf-set-selections <<< "tripwire tripwire/use-localkey boolean true"
debconf-set-selections <<< "tripwire tripwire/use-sitekey boolean true"

apt install -y tripwire

# -----------------------------------------------------------------------------
# Passphrases — change these before any real deployment
# -----------------------------------------------------------------------------
SITE_PASS="ACMEsite2024!"
LOCAL_PASS="ACMElocal2024!"
HOSTNAME=$(hostname)

# -----------------------------------------------------------------------------
# Generate site and local keys
# -----------------------------------------------------------------------------
echo "[tripwire] Generating keys..."

twadmin --generate-keys \
    --site-keyfile /etc/tripwire/site.key \
    --site-passphrase "$SITE_PASS"

twadmin --generate-keys \
    --local-keyfile "/etc/tripwire/${HOSTNAME}-local.key" \
    --local-passphrase "$LOCAL_PASS"

# -----------------------------------------------------------------------------
# Sign config file
# -----------------------------------------------------------------------------
twadmin --create-cfgfile \
    --site-keyfile /etc/tripwire/site.key \
    --cfgfile /etc/tripwire/tw.cfg \
    --site-passphrase "$SITE_PASS" \
    /etc/tripwire/twcfg.txt

# -----------------------------------------------------------------------------
# Sign policy file
# -----------------------------------------------------------------------------
twadmin --create-polfile \
    --site-keyfile /etc/tripwire/site.key \
    --site-passphrase "$SITE_PASS" \
    /etc/tripwire/twpol.txt

# -----------------------------------------------------------------------------
# Initialize the baseline database
# This snapshot represents the "known good" state of the filesystem
# -----------------------------------------------------------------------------
echo "[tripwire] Initializing baseline database (this may take a minute)..."

tripwire --init --local-passphrase "$LOCAL_PASS"

echo "[tripwire] Baseline initialized."
echo "[tripwire] Run a check: sudo tripwire --check"
echo "[tripwire] Passphrases are set in this script — change SITE_PASS and LOCAL_PASS for any non-lab use."