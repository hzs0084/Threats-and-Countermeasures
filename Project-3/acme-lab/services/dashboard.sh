#!/bin/bash
# =============================================================================
# ACME IT Corp - Next.js Health Dashboard Setup
# =============================================================================
# Installs Node.js 20, creates the ACME health dashboard app, and registers
# it as a systemd service on port 3000.
#
# Run independently:  sudo ./services/dashboard.sh
# Called by:          setup.sh
#
# Port: 3000 (also proxied via Apache at /health-check)
#
# NOTE: This script deploys a CLEAN dashboard without the eval() RCE.
#       The vulnerability is injected by vulnerabilities/nodejs_rce.sh.
# =============================================================================

set -euo pipefail

echo "[dashboard] Installing Node.js 20..."

curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs
node -v

# -----------------------------------------------------------------------------
# Create application directory
# -----------------------------------------------------------------------------
mkdir -p /opt/acme-next-dashboard/pages
mkdir -p /opt/acme-next-dashboard/public

# -----------------------------------------------------------------------------
# package.json
# -----------------------------------------------------------------------------
cat > /opt/acme-next-dashboard/package.json << 'EOF'
{
  "name": "acme-next-dashboard",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint"
  },
  "dependencies": {
    "next": "16.1.6",
    "react": "latest",
    "react-dom": "latest"
  }
}
EOF

# -----------------------------------------------------------------------------
# Clean dashboard page (no eval vulnerability)
# The RCE version is written by vulnerabilities/nodejs_rce.sh
# -----------------------------------------------------------------------------
cat > /opt/acme-next-dashboard/pages/dashboard.js << 'EOF'
import React from 'react';

export default function Dashboard({ systemInfo, error, currentUser }) {
  return (
    <div style={{
      backgroundColor: '#0b1220',
      backgroundImage: 'radial-gradient(1000px 600px at 20% 0%, #12224a, #0b1220)',
      minHeight: '100vh',
      color: '#e8eefc',
      fontFamily: 'system-ui, -apple-system, sans-serif',
      padding: '24px',
    }}>
      <div style={{ maxWidth: '980px', margin: '0 auto' }}>

        {/* Header */}
        <div style={{
          display: 'flex', justifyContent: 'space-between', alignItems: 'center',
          padding: '14px 18px', border: '1px solid #223257', borderRadius: '12px',
          background: 'rgba(15, 26, 51, 0.65)', backdropFilter: 'blur(8px)'
        }}>
          <div style={{ fontWeight: 700 }}>
            ACME IT Corp <span style={{
              display: 'inline-block', padding: '2px 8px', borderRadius: '999px',
              border: '1px solid #223257', color: '#9db0d1', fontSize: '12px', marginLeft: '8px'
            }}>internal health portal</span>
          </div>
          <div style={{ fontSize: '14px', color: '#9db0d1' }}>
            User: <span style={{ color: '#6ea8fe' }}>{currentUser}</span>
          </div>
        </div>

        {/* Diagnostic Panel */}
        <div style={{
          marginTop: '18px', padding: '24px', border: '1px solid #223257',
          borderRadius: '12px', background: 'rgba(15, 26, 51, 0.75)'
        }}>
          <h1 style={{ fontSize: '22px', margin: '0 0 10px' }}>System Diagnostics v1.0b</h1>
          <p style={{ color: '#9db0d1', margin: '6px 0 20px', fontSize: '14px' }}>
            Authorized access only. Unauthorized access is prohibited and monitored.
          </p>
          <div style={{ padding: '12px', border: '1px solid #223257', borderRadius: '12px', background: 'rgba(11, 20, 42, 0.5)' }}>
            <h2 style={{ fontSize: '14px', margin: '0 0 8px', textTransform: 'uppercase', color: '#6ea8fe' }}>Diagnostic Output</h2>
            <pre style={{ background: '#0b142a', padding: '10px', borderRadius: '10px', color: '#6fcf6f', fontSize: '12px', border: '1px solid #223257' }}>
              {systemInfo || "System standby. Diagnostics active."}
            </pre>
          </div>
        </div>

        {/* Footer */}
        <div style={{ marginTop: '22px', color: '#9db0d1', fontSize: '12px', textAlign: 'center' }}>
          © 2026 ACME IT Corp • Internal Portal v2.6.14 • <span style={{ color: '#6ea8fe', opacity: 0.8 }}>Built by Next.js</span>
        </div>
      </div>
    </div>
  );
}

export async function getServerSideProps(context) {
  const { query } = context;
  const currentUser = query.user || 'fongling';
  const systemInfo = "System standby. Diagnostics active.";
  return { props: { systemInfo, currentUser } };
}
EOF

# -----------------------------------------------------------------------------
# Install dependencies and build
# -----------------------------------------------------------------------------
cd /opt/acme-next-dashboard
npm install
npm run build

# -----------------------------------------------------------------------------
# Systemd service
# -----------------------------------------------------------------------------
cat > /etc/systemd/system/acme-health.service << 'EOF'
[Unit]
Description=ACME Health Dashboard (Next.js)
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/acme-next-dashboard
ExecStart=/usr/bin/npm run start
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable acme-health
systemctl start acme-health

echo "[dashboard] Next.js dashboard running on port 3000."
echo "[dashboard] Proxied via Apache at: http://192.168.56.21/health-check"
echo "[dashboard] To inject RCE: run vulnerabilities/nodejs_rce.sh"