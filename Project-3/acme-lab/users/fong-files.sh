#!/bin/bash

# Configuration
USER_FONG="fongling"
HOME_FONG="/home/$USER_FONG"

echo "[+] Expanding Fong Ling's workspace with high-detail web development content..."

# 1. Create Additional Directory Structure
mkdir -p $HOME_FONG/{CSS_Assets,Drafts/v1_Archive,Contractor_Admin,Communication,PHP_References,Deployment_Logs}

# 2. Contractor Admin (Reflecting their status)
cat << 'EOF' > $HOME_FONG/Contractor_Admin/Contract_Renewal_Note.txt
Note to self:
My current 6-month contract extension ends in July 2026. 
I need to show Mallory the completed 'About Us' redesign and the 
new upload portal to justify the next extension. Claire has been 
great with the invoicing, but Mallory is the one who signs off on 
the hours.
EOF

cat << 'EOF' > $HOME_FONG/Contractor_Admin/Timesheet_Mar_2026.csv
Date,Task,Hours,Status
2026-03-02,CSS Debugging (Mobile View),6,Submitted
2026-03-05,Upload Module Validation Logic,8,In Progress
2026-03-10,Meeting with Bob regarding marketing assets,2,Submitted
2026-03-12,Server side image processing script,4,Submitted
EOF

# 3. Communication (Interactions with Bob and Mallory)
cat << 'EOF' > $HOME_FONG/Communication/Bob_Marketing_Assets.txt
Fong, 
I'm sending over the high-res photos from the 20th Anniversary dinner. 
Please get these onto the 'History' page ASAP. Also, the contact form 
needs to be able to handle PDF resumes for the new intern openings. 
Let me know when the upload limit is increased.
- Bob
EOF

cat << 'EOF' > $HOME_FONG/Communication/Mallory_Feedback_Urgant.txt
Fong, 
The site looks better, but it's still running a bit slow on my 
workstation. Are you sure the on-premises hosting can handle the 
new high-res images Bob is sending you? Check with Mitch if we 
need to adjust the Apache memory limits.
- Mallory
EOF

# 4. Web Development Context (Junior Dev learning curve)
cat << 'EOF' > $HOME_FONG/PHP_References/File_Upload_CheatSheet.md
# Notes on PHP File Uploads
- `move_uploaded_file()` is the core function.
- Remember to check `$_FILES['userfile']['error']`.
- *To-Do*: Implement MIME type checking. Alice mentioned using 
  `finfo_file` for better security, but for now, checking the 
  extension `.jpg` and `.png` is what I have working.
- *Issue*: I keep getting permission denied errors in /var/www/uploads. 
  Eve said she’d look into it.
EOF

# 5. Deployment Logs (Real-world "oops" moments)
cat << 'EOF' > $HOME_FONG/Deployment_Logs/Deploy_v1.2_Notes.log
2026-02-15: Initial push of the redesigned homepage.
2026-02-16: Fixed broken link in the footer.
2026-03-01: Upload directory moved to a separate partition per Mitch’s 
            request to avoid filling up the root drive.
2026-03-10: Bob complained that the contact form was timing out. 
            Optimized the image resizing script to handle large 
            files from his camera.
EOF

# 6. Drafts & Archive (The "Messy" Dev)
cat << 'EOF' > $HOME_FONG/Drafts/v1_Archive/Old_Header_Mockup.html
<div style="background-color: #FF5733;">
  <h1>ACME IT Corp - Managed Services</h1>
</div>
EOF

# 7. Relational Depth (Connecting to Claire's seedling note)
cat << 'EOF' > $HOME_FONG/Notes/Office_Life.txt
- Claire asked if I wanted any tomato seedlings from Alice. 
- Bob is always asking for "one more small change" to the CSS.
- Mitch is hard to find, but he's the only one who can help with 
  the FTP server configuration.
EOF

# Set Ownership and Permissions
chown -R $USER_FONG:$USER_FONG $HOME_FONG
echo "[+] Fong Ling's environment expansion complete."
