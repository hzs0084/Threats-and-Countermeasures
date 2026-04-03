#!/bin/bash

# Configuration
USER="alicebrown"
HOME_DIR="/home/$USER"

echo "[+] Expanding Alice Brown's workspace with high-detail work content..."

# 1. Expand Directory Structure
mkdir -p $HOME_DIR/{Internal_Documentation,Vendor_Management,Hardware_Lifecycle,Archive/2010s,Email_Drafts,Personal_Folder}

# 2. Internal Documentation (SOPs and Guides)
cat << 'EOF' > $HOME_DIR/Internal_Documentation/New_Hire_Onboarding_IT.md
# IT Onboarding Checklist
- Assign standard workstation (see Hardware_Lifecycle/Approved_Models.txt).
- Issue encrypted USB for emergency recovery.
- Set up company email (FirstnameLastname@acmeit.local).
- Conduct password security briefing (Explain that we use password managers, no exceptions).
- Review the "No Microsoft" vendor policy.
EOF

cat << 'EOF' > $HOME_DIR/Internal_Documentation/Server_Room_Maintenance.txt
Weekly Server Room Check:
- Verify AC unit is holding at 68 degrees.
- Dust the intake fans on Host-01 and Host-02.
- Check the physical paper audit log for the server rack key.
- Note: Mitch keeps leaving his coffee mugs on the UPS. Tell him to stop.
EOF

# 3. Hardware Lifecycle and Vendor Management
cat << 'EOF' > $HOME_DIR/Hardware_Lifecycle/Approved_Models.txt
Standard Issue (2025-2026):
- Laptop: Dell Latitude 5000 Series (Linux Pre-installed)
- Desktop: OptiPlex Small Form Factor
- Monitors: Dell UltraSharp 27"
Note: We are strictly a Dell shop for hardware to simplify the spare parts inventory.
EOF

cat << 'EOF' > $HOME_DIR/Vendor_Management/ISP_Contract_Renewal.md
# ISP Renewal Notes - Q1 2026
Our current contract with the fiber provider expires in June. 
I've requested a quote for a 1Gbps symmetric line. 
Mallory wants to know if they provide a service level agreement (SLA) 
of 99.9% uptime since we host the site on-premises.
EOF

# 4. Email Drafts (Reflecting interactions with other staff)
cat << 'EOF' > $HOME_DIR/Email_Drafts/To_Fong_Re_Web_Uploads.txt
Subject: RE: Web folder permissions
Fong, 
I saw your note about the /var/www/uploads/ folder. 
I've adjusted the permissions so the web user can write to it, but 
please ensure your script is scrubbing those files properly. 
We don't want any garbage filling up the disk.
- Alice
EOF

cat << 'EOF' > $HOME_DIR/Email_Drafts/To_Mitch_Password_Audit.txt
Subject: Password Audit Forms
Mitch, 
I'm still missing your signed paper audit form for this month. 
I know you're busy with the FTP server, but Mallory is breathing 
down my neck about compliance. Just drop it on my desk before you leave.
EOF

# 5. Archive (Reflecting 17 years of history)
cat << 'EOF' > $HOME_DIR/Archive/2010s/Office_Move_Inventory_2013.txt
Inventory from the 2013 office expansion:
- 4x CRT monitors (Recycled)
- 1x Server Rack (Relocated)
- 6x Ergo Chairs
- 1x "World's Best IT" Mug (Alice's)
EOF

# 6. Personal (Non-technical life)
cat << 'EOF' > $HOME_DIR/Personal_Folder/Gardening_Club_Notes.txt
Spring 2026 Planting:
- Heirloom Tomatoes (Start seeds indoors March 1st)
- Bell Peppers
- Lavender (For the front porch)
Ask Claire if she wants any of the extra seedlings this year.
EOF

# Set Ownership and Permissions
chown -R $USER:$USER $HOME_DIR
echo "[+] Alice's deep-content environment is now fully populated."
