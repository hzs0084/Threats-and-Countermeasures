#!/bin/bash

# Configuration
USER="alicebrown"
HOME_DIR="/home/$USER"

echo "[+] Injecting 17 years of IT history into $USER's workspace..."

# 1. New Highly-Detailed Directories
mkdir -p $HOME_DIR/{Compliance_Audits,Network_Diagrams,Vendor_Contracts/Hardware,Project_Archive/2018_Migration,Maintenance_Logs}

# 2. Compliance and Policy (Reflecting ACME's strict posture)
cat << 'EOF' > $HOME_DIR/Compliance_Audits/Monthly_Compliance_Checklist.md
# ACME IT Corp - Security Compliance (Internal)
* **Status**: In Progress - March 2026
* **OS Updates**: Verify all workstations are within 14-day patch window.
* **Password Rotation**: Collect paper audit forms from all 6 staff members.
    - [X] Alice Brown
    - [ ] Mitch Marcus (Always late)
    - [X] Mallory Martinez
    - [X] Bob Barker
    - [X] Claire Redfield
    - [X] Eve Johnson
* **Physical Security**: Server rack key verified in safe.
EOF

# 3. Hardware Lifecycle (Reflecting her role in maintenance)
cat << 'EOF' > $HOME_DIR/Vendor_Contracts/Hardware/Dell_Replacement_Schedule.csv
Device_ID,Assigned_To,Model,Warranty_Exp,Status
WS-01,Mitch Marcus,OptiPlex 7000,2027-05-12,Active
WS-02,Bob Barker,Latitude 5420,2025-08-30,SCHEDULE REPLACEMENT
WS-03,Alice Brown,Precision 3660,2028-01-15,Active
SRV-01,N/A,PowerEdge R640,2026-11-20,Renewal Pending
EOF

# 4. Maintenance Logs (Relatable "IT chores")
cat << 'EOF' > $HOME_DIR/Maintenance_Logs/Server_Room_Climate.log
2026-03-01: Temp 68F, Humidity 45%. Filters cleaned.
2026-03-08: Temp 69F, Humidity 44%. Noted dust buildup on Host-01.
2026-03-15: Temp 68F, Humidity 45%. Mitch left a half-empty soda can on the UPS. Discarded it.
EOF

# 5. Project Archive (Reflecting long-term tenure)
cat << 'EOF' > $HOME_DIR/Project_Archive/2018_Migration/Migration_Notes.txt
Post-Migration Review (August 2018):
We successfully moved the primary web server to the new hardware. 
Mallory insisted on keeping it on-premises despite the cost of the 
new fiber line. It’s more work for us, but better for 
the 'distrust of external providers' policy.
EOF

# 6. Legacy Work (Standard IT "Hoarding")
cat << 'EOF' > $HOME_DIR/Archive/Legacy_Scripts_Reference.txt
Note: I moved the old 2009-era Perl scripts for user creation to the 
deep archive. We use the bash automation now, but keep them for 
reference in case we ever have to recover the old legacy DB.
EOF

# 7. Office Culture / Personal
cat << 'EOF' > $HOME_DIR/Personal_Folder/Office_Potluck_Signups.txt
ACME Spring Potluck (April 5th):
- Alice: Garden Salad (Heirloom tomatoes)
- Bob: Napkins and sodas
- Claire: Potato Salad
- Mitch: Store-bought cookies (again)
- Eve: Chicken Wings
- Fong: Spring Rolls
EOF

cat << 'EOF' > $HOME_DIR/Network_Diagrams/Office_Layout.txt
[SOHO Layout - 2026]
Front Office: Bob Barker (Reception/Sales)
Middle Office: Claire Redfield & Fong Ling
Back Office: Alice Brown & Mitch Marcus
Manager Office: Mallory Martinez
Storage Closet: The "Server Room" (Keep locked)
EOF

# Set Ownership and Permissions
chown -R $USER:$USER $HOME_DIR
echo "[+] Alice Brown's environment is now hyper-realistic."
