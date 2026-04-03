#!/bin/bash

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# List of all users in the lab
users=("mitchmarcus" "mallorymartinez" "alicebrown" "bobbarker" "claireredfield" "evejohnson" "fongling")

echo "[+] Generating hyper-realistic noise and rabbit holes for all users..."

for user in "${users[@]}"; do
    HOME_DIR="/home/$user"
    
    # 1. Create standard dummy directories
    mkdir -p $HOME_DIR/{Desktop,Documents,Downloads,Music,Pictures}

    # 2. Add "Normie" Content (Universal Noise)
    touch $HOME_DIR/Music/Work_Focus_Playlist.m3u
    touch $HOME_DIR/Pictures/Office_Potluck_Group_Photo.png
    echo "Check out the local farmers market schedule for 2026." > $HOME_DIR/Documents/Weekend_Plans.txt

    # 3. User-Specific Distractions (Rabbit Holes)
    case $user in
        "mitchmarcus")
            # Mitch manages the FTP service[cite: 30, 99].
            echo "Drafting new FTP banner - Mitch" > $HOME_DIR/Desktop/Banner_Idea.txt
            touch $HOME_DIR/Downloads/vsftpd_update.tar.gz
            echo "Order more espresso pods for the breakroom." >> $HOME_DIR/Documents/To_Do.txt
            ;;

        "bobbarker")
            # Bob is the Director of Customer Relations[cite: 11].
            echo "LinkedIn Best Practices for 2026" > $HOME_DIR/Documents/Networking_Tips.odt
            touch $HOME_DIR/Pictures/Bob_Barker_Headshot_Professional.jpg
            echo "Drafting my 20th anniversary speech..." > $HOME_DIR/Desktop/Speech_Scratchpad.txt
            ;;

        "alicebrown")
            # Alice is a long-tenured IT Specialist and gardener[cite: 7, 8].
            echo "Tomato Planting Chart - Spring 2026" > $HOME_DIR/Documents/Garden_Layout.odt
            touch $HOME_DIR/Pictures/Heirloom_Tomatoes_Reference.jpg
            echo "Old network diagrams from 2009 - do not delete." > $HOME_DIR/Desktop/Legacy_Reference.txt
            ;;

        "claireredfield")
            # Claire is the Accountant[cite: 15, 18].
            echo "Monthly reconcile for Feb 2026 completed." > $HOME_DIR/Documents/Status_Update.txt
            touch $HOME_DIR/Downloads/Tax_Form_Draft_2025.pdf
            echo "Remember to coordinate with Alice for the PC cert update." > $HOME_DIR/Desktop/Sticker_Note.txt
            ;;

        "evejohnson")
            # Eve is the Systems Support Tech and a gym-goer[cite: 19, 22].
            echo "Leg Day Routine - Week 4" > $HOME_DIR/Documents/Gym_Progress.odt
            touch $HOME_DIR/Downloads/Snort_Rule_Update_Log.txt
            echo "The printer in Bob's office is jamming again." > $HOME_DIR/Desktop/Reminders.txt
            ;;

        "fongling")
            # Fong is the Junior Web Dev Contractor[cite: 40].
            echo "Reviewing PHP move_uploaded_file() documentation." > $HOME_DIR/Documents/PHP_Study_Notes.txt
            touch $HOME_DIR/Downloads/bootstrap-5.3.0-dist.zip
            echo "Mallory wants the 'About Us' page to look 'cleaner'." > $HOME_DIR/Desktop/Feedback_Log.txt
            ;;

        "mallorymartinez")
            # Mallory is the Head of IT and Security[cite: 25].
            echo "Reviewing the 2026 security audit scope." > $HOME_DIR/Documents/Management_Review.txt
            touch $HOME_DIR/Music/Strategy_Meeting_Recording_Mar10.mp3
            echo "CONFIDENTIAL: Security policy amendment drafts." > $HOME_DIR/Desktop/Top_Priority.txt
            ;;
    esac

    # 4. Set Ownership
    chown -R $user:$user $HOME_DIR
done

echo "[+] Noise generation complete. The environments now look cluttered and 'lived-in'."
