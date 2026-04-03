#!/bin/bash

# Configuration
USER_CLAIRE="claireredfield"
HOME_CLAIRE="/home/$USER_CLAIRE"

echo "[+] Expanding Claire Redfield's workspace with high-detail accounting content..."

# 1. Create Additional Directory Structure
mkdir -p $HOME_CLAIRE/{Invoices,Regulatory_Filings,Expense_Reports,Budget_Planning,Legacy_Ledgers,Audit_Prep,Personal_Records}

# 2. Budget Planning (Connecting to other staff needs)
cat << 'EOF' > $HOME_CLAIRE/Budget_Planning/FY2026_Hardware_Refresh_Final.md
# FY 2026 Hardware Budget Notes
**Coordinator:** Alice Brown
**Status:** Approved by Mallory Martinez

Allocated: $15,000 for server upgrades and workstation refreshes.
- Priority 1: Replace Bob's laptop (Requested Feb 2026).
- Priority 2: PowerEdge renewal for Host-01.
- Priority 3: General IT peripherals for Eve's support desk.

*Note: Mallory wants the physical receipts for all hardware filed in the 
on-site cabinet. No digital-only records for high-value assets.*
EOF

# 3. Expense Reports (Real-world "paper trail")
cat << 'EOF' > $HOME_CLAIRE/Expense_Reports/Employee_Reimbursements_Mar26.csv
Date,Employee,Description,Amount,Status
2026-03-02,Bob Barker,Client Lunch (Initech),74.50,Approved
2026-03-05,Alice Brown,Server Cleaning Supplies,22.15,Approved
2026-03-10,Eve Johnson,Cable Management Kits,45.00,Pending
2026-03-12,Mitch Marcus,Replacement SATA Cables,18.99,Approved
EOF

# 4. Contractor Management (Fong Ling's status)
cat << 'EOF' > $HOME_CLAIRE/Invoices/Contractor_Invoice_FongLing_Feb26.txt
Invoice #: ACME-FL-2026-02
Contractor: Fong Ling (Junior Web Developer) [cite: 40]
Service: Website redesign and upload module maintenance. [cite: 41, 45]
Hours: 40 hours @ $45/hr
Total: $1,800.00
Status: Paid 03/01/2026
Note: Mallory requested a 1099 form update for Fong this year.
EOF

# 5. Regulatory & Tax (The "Accountant" burden)
cat << 'EOF' > $HOME_CLAIRE/Regulatory_Filings/State_Tax_Compliance_Note.txt
Reminder for Q1 2026:
The Alabama state tax filing is due April 15. 
I need Mitch to confirm the final inventory of our on-premises hardware 
assets for the property tax depreciation schedule. He hasn't responded 
 to my last three emails. I might have to go back to his desk and 
ask him in person. [cite: 3]
EOF

# 6. Legacy Ledgers (Inherited documents)
cat << 'EOF' > $HOME_CLAIRE/Legacy_Ledgers/Archive_Migration_2021.txt
Notes on taking over the books:
When I started in Sept 2021, the financial records for the 2010s 
were a bit disorganized—likely a side effect of the "incident" they 
had back then[cite: 50, 52]. I've since moved everything into our current 
ledger format. Mallory still prefers paper backups for everything[cite: 55].
EOF

# 7. Audit Prep (Process and Security)
cat << 'EOF' > $HOME_CLAIRE/Audit_Prep/Internal_Audit_Checklist.md
# Internal Financial Audit Checklist
- [ ] Reconcile monthly bank statements.
- [X] Verify payroll for all 6 employees. [cite: 1]
- [ ] Confirm Alice has updated the certs on the accounting PC.
- [ ] Audit the "Paper Audit" vault (Check Mallory's office). [cite: 37]
EOF

# 8. Personal (Adding the "Lived-in" feel)
cat << 'EOF' > $HOME_CLAIRE/Personal_Records/Potluck_Seedlings.txt
Potluck/Gardening Notes:
Alice is bringing heirloom tomato seedlings. I should bring some 
pots and soil. Ask if she needs help with the salad prep.
Reminder: Bob's birthday is in May—organize a card.
EOF

# Set Ownership and Permissions
chown -R $USER_CLAIRE:$USER_CLAIRE $HOME_CLAIRE
echo "[+] Claire Redfield's environment expansion complete."
