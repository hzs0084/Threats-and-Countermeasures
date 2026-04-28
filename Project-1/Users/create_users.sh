#!/bin/bash

# Ensure the script is run with root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root (use sudo)."
   exit 1
fi

# Define the users
INTERACTIVE_USERS=("alice" "bob" "eve")
GROUP_USER="mallory"
TARGET_GROUP="users"

echo "--- Starting User Creation Process ---"

# 1. Create Alice, Bob, and Eve and set passwords interactively
for user in "${INTERACTIVE_USERS[@]}"; do
    if id "$user" &>/dev/null; then
        echo "User '$user' already exists. Skipping creation..."
    else
        echo "Creating user: $user"
        useradd -m -s /bin/bash "$user"
        echo "Please set the password for $user:"
        passwd "$user"
        echo "---------------------------------------"
    fi
done

# 2. Create Mallory and add her to the 'users' group
if id "$GROUP_USER" &>/dev/null; then
    echo "User '$GROUP_USER' already exists."
else
    echo "Creating user: $GROUP_USER"
    # -m creates home directory, -g sets the primary group to 'users'
    useradd -m -s /bin/bash -g "$TARGET_GROUP" "$GROUP_USER"
    
    # Optional: If you want Mallory to have no password (locked account) 
    # or a default one, you can add that here. 
    # For now, she is created without a password set.
    echo "User '$GROUP_USER' created and added to group '$TARGET_GROUP'."
fi

echo "--- Process Complete ---"