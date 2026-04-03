#!/bin/bash

# Configuration
USER_MALLORY="mallorymartinez"
HOME_MALLORY="/home/$USER_MALLORY"

echo "[+] Expanding Mallory Martinez's workspace with high-detail Security & Management content..."

# 1. Create Additional Directory Structure
mkdir -p $HOME_MALLORY/{Security_Operations,Board_Reports,Personnel_Management,Legal_and_Contracts,Audit_Vault,Personal_Archive}

# 2. Security Operations (Relating to the current lab narrative)
cat << 'EOF' > $HOME_MALLORY/Security_Operations/Pentest_Kickoff_Notes_2026.md
# Engagement: 2026 Network Security Assessment
**Status:** Authorized / Active
**Point of Contact:** Mallory Martinez [cite: 25, 26]

**Objectives:**
- Evaluate effectiveness of on-premises hosting security.
- Test junior contractor's (Fong Ling) web implementation.
- Validate that the 2010s breach corrective actions are holding.
- Monitor for unauthorized privilege escalation (Root monitoring active).

*Note: Any root activity not initiated by my account should trigger an 
automated lockout. Ensure Alice has the backup physical key for the 
server room in case of a system-wide freeze.*
EOF

# 3. Personnel Management (Observations on the team)
cat << 'EOF' > $HOME_MALLORY/Personnel_Management/Staff_Review_Drafts_2026.txt
CONFIDENTIAL - Performance Notes:

Mitch Marcus: Technical skills remain top-tier, but compliance is 
lapsing. Still struggling to get him to submit paper audit forms 
on time. His reliance on the same patterns for the FTP server 
remains a concern I need to address formally.

Alice Brown: Exceptional as always. Her meticulousness with 
documentation and hardware inventory is the backbone of this office. 

Fong Ling: Good progress on the site redesign. However, as a junior 
contractor, their understanding of secure coding (specifically file 
handling) needs closer supervision. I've asked Eve to monitor the 
uploads directory more frequently.
EOF

# 4. Legal and Contracts (Enforcing the company's "No Microsoft" stance)
cat << 'EOF' > $HOME_MALLORY/Legal_and_Contracts/Vendor_Policy_Statement.pdf.txt
ACME IT Corp - Vendor Neutrality and Security Policy
Established: 2013 (Amended 2025)

It is the standing policy of ACME IT Corp to prohibit the use of 
Microsoft products and cloud-hosted third-party services for core 
infrastructure[cite: 55]. 
Reasons: Distrust of vendor telemetry and history of external breaches. 
All technical staff are required to use approved open-source or 
hardened Linux alternatives for daily operations.
EOF

# 5. Board/Management Reports (The 20-year milestone)
cat << 'EOF' > $HOME_MALLORY/Board_Reports/Q1_2026_Executive_Summary.md
# Q1 2026 Executive Summary
**Author:** Mallory Martinez, Head of IT/Security 

**Highlights:**
- Successfully celebrated 20 years of continuous operation[cite: 2].
- On-premises infrastructure handled the Q1 traffic spike with 99.9% uptime.
- Budget for 2026 hardware refresh has been handed to Claire for processing.
- Security posture remains "High" following the implementation of our 
  manual paper-audit trail for credentials.
EOF

# 6. Audit Vault (Process and Security Awareness)
cat << 'EOF' > $HOME_MALLORY/Audit_Vault/Credential_Policy_Review.txt
Monthly Credential Audit Protocol:
As the primary technical stakeholder, I must lead by example. My 
personal passphrase remains at the 7-word minimum to ensure 
maximum entropy. 
Reminder: Paper audit forms are to be stored in the physical safe 
underneath my desk. Only Alice has the secondary combination.
EOF

# 7. Personal Archive (Tenure and Office Life)
cat << 'EOF' > $HOME_MALLORY/Personal_Archive/Anniversary_Dinner_Photos.txt
Note: Bob did a great job with the 20th-anniversary speech. 
I've asked Fong to put the photos from the dinner on the company 
history page. It's important for the clients to see that we've 
been here since 2002[cite: 2].
EOF

# Set Ownership and Permissions
chown -R $USER_MALLORY:$USER_MALLORY $HOME_MALLORY
# Mallory is the only authorized root user
usermod -aG sudo $USER_MALLORY
echo "[+] Mallory Martinez's environment expansion complete. (Authorized Root set)."
