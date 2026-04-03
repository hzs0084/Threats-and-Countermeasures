#!/bin/bash

# Configuration
USER="bobbarker"
HOME_DIR="/home/$USER"

echo "[+] Expanding Bob Barker's workspace with high-detail business content..."

# 1. Create Additional Directory Structure
mkdir -p $HOME_DIR/{Client_Correspondence,Drafts,Marketing_Materials,Company_History,Internal_Memos,Event_Planning}

# 2. Company History & Milestone Content
cat << 'EOF' > $HOME_DIR/Company_History/20th_Anniversary_Speech_Draft.txt
DRAFT: ACME IT Corp 20th Anniversary Dinner (Nov 2022)
Speaker: Bob Barker

"When I joined Mallory and the team back in 2010, we were still finding our 
footing in the local MSP market. Today, looking around this room—or well, 
this office—at Alice, Mitch, and our newer faces like Claire and Eve, I'm 
reminded why we stay independent. 20 years of keeping data on-premises and 
keeping our clients' trust. Here's to 20 more."
EOF

cat << 'EOF' > $HOME_DIR/Company_History/Founding_Values_Review.md
# ACME IT Corp - Core Values (Revised 2024)
1. **Client Sovereignty**: Their data stays on our hardware, not in a generic cloud.
2. **Longevity**: We build relationships that last decades, not contract cycles.
3. **Transparency**: Paper-based audits and direct access to technicians.
Note: Mallory wants these integrated into the new website design (Fong's project).
EOF

# 3. Client Correspondence (Relational depth)
cat << 'EOF' > $HOME_DIR/Client_Correspondence/Initech_Followup_Notes.txt
Date: 2026-03-10
Client: Bill Lumbergh (Initech)
Notes: 
Bill is still frustrated with the printer drivers on the third floor. 
I told him Eve is working on a new setup guide. He also asked about 
scaling their storage. I need to check with Mitch to see if we have 
room on the current FTP array or if we need to quote a new rack.
EOF

cat << 'EOF' > $HOME_DIR/Client_Correspondence/CyberDyne_SOC_Quote_Draft.txt
RE: Managed SOC Services
Miles, 
It was great catching up last week. Attached is the preliminary 
quote for the managed security monitoring. Alice and Eve have 
vetted the Snort rule set we'll be deploying for your edge. 
Let's discuss the hardware lead times on Thursday.
EOF

# 4. Marketing & Public Presence (LinkedIn focus)
cat << 'EOF' > $HOME_DIR/Marketing_Materials/Newsletter_Draft_Q2.txt
ACME INSIDER - Q2 2026
"Why On-Prem Still Matters in 2026"
In an era of massive third-party data breaches, ACME IT Corp remains 
committed to the security of physical, local hosting. Read more about 
how Alice Brown and our technical team maintain our air-gapped 
backup protocols...
EOF

# 5. Internal Memos & Relational Context
cat << 'EOF' > $HOME_DIR/Internal_Memos/Workstation_Refresh_Request.txt
To: Alice Brown
From: Bob Barker
Date: 2026-02-15
Subject: Replacement Laptop
Alice, 
My Latitude is starting to chug when I have more than three CRM tabs 
open. I saw the Dell quote on your desk—any chance I'm at the top 
of the list for the refresh? I've got three on-site demos next 
month and I'd rather not have it freeze mid-pitch.
EOF

cat << 'EOF' > $HOME_DIR/Internal_Memos/CRM_Access_Issues.txt
Note to self:
Claire is still waiting on that legacy CRM export for the Q1 
reconciliation. Mallory needs to sign off on the permission 
elevation before Alice can run the script. Remind Mallory during 
the Monday sync.
EOF

# 6. Event Planning (The "Office Culture" layer)
cat << 'EOF' > $HOME_DIR/Event_Planning/Spring_Potluck_Logistics.txt
Spring Potluck 2026 - Bob's Tasks:
- Coordinate with the Downtown Grill for the main tray.
- Ensure the "Server Room" closet is locked and the hallway is clear.
- Buy extra napkins (Alice specifically mentioned we ran out last time).
- Remind Mitch no soda cans near the equipment.
EOF

# 7. Relational "Add-on" to existing files (Appending instead of overwriting)
echo "Follow up with Miles regarding the SOC quote signature." >> $HOME_DIR/Drafts/LinkedIn_Post.txt

# Set Ownership and Permissions
chown -R $USER_BOB:$USER_BOB $HOME_DIR
echo "[+] Bob Barker's environment is now hyper-realistic."
