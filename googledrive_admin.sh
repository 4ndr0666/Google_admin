#!/bin/bash

# Configuration
BASE_DIR="/Nas2/Gdrive"  # Replace with your Google Drive base directory
BACKUP_DIR="/Nas2/Gdrive/backup" # Replace with your backup directory
SOURCE_DIRS=("/Nas2/Gdrive/iphotos backup" "/Nas2/Gdrive/webdav") # Replace with your source directories
LOG_FILE="gdrive_admin.log"
FILE_TYPES=("json" "pdf" "md" "xml" "html" "tar" "zip" "tar.gz" "iso" "wim")

# Menu options
options=("Organize Files by Type and Date" "Rename Files" "Backup Important Directories" "Deduplicate Files" "Quit")


# Function for logging
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to organize files by type and date
organize_files() {
    log "Starting to organize files by type and date..."
    for type in "${FILE_TYPES[@]}"; do
        find "$BASE_DIR" -type f -name "*.$type" -print0 | while IFS= read -r -d '' file; do
            # Get the file's last modification date
            date=$(stat -c %y "$file" | cut -d' ' -f1 | tr -d '-')
            # Create the target directory
            target_dir="$BASE_DIR/$type/$date"
            mkdir -p "$target_dir"
            # Move the file
            if mv "$file" "$target_dir"; then
                log "Moved $file to $target_dir"
            else
                log "Error moving $file to $target_dir"
            fi
        done
    done
    log "Finished organizing files by type and date."
}

# Function to rename files
rename_files() {
    log "Starting to rename files..."
    find "$BASE_DIR" -type f -print0 | while IFS= read -r -d '' file; do
        # Get the file's last modification date and original name
        date=$(stat -c %y "$file" | cut -d' ' -f1)
        name=$(basename "$file")
        # Create the new name and rename the file
	new_name="$BASE_DIR/${date}_$name"
        if mv "$file" "$new_name"; then
            log "Renamed $file to $new_name"
        else
            log "Error renaming $file to $new_name"
        fi
    done
    log "Finished renaming files."
}

# Function to backup important directories
backup_dirs() {
    log "Starting to backup important directories..."
    for dir in "${SOURCE_DIRS[@]}"; do
        # Get the directory name
        name=$(basename "$dir")
        # Create the target directory
        target_dir="$BACKUP_DIR/$name"
        mkdir -p "$target_dir"
        # Copy the files
        if cp -r "$dir" "$target_dir"; then
            log "Backed up $dir to $target_dir"
        else
            log "Error backing up $dir to $target_dir"
        fi
    done
    log "Finished backing up important directories."
}

# Function to deduplicate files
deduplicate_files() {
    echo "Enter the directory you want to deduplicate:"
    read -r dir
    if [ -d "$dir" ]; then
        log "Starting to deduplicate files in $dir..."
        if jdupes -r "$dir" -o name -A -s -N --linkhard -m "$TRASH_DIR"; then
            log "Deduplication complete."
        else
            log "Error during deduplication."
        fi
    else
        log "Directory $dir does not exist."
    fi
}

# Main menu
while true; do
    echo "Google Drive Admin Menu"
    echo "======================="
    PS3="Please enter your choice: "
    select opt in "${options[@]}"; do
        case $REPLY in
            1) organize_files ;;
            2) rename_files ;;
            3) backup_dirs ;;
            4) deduplicate_files ;;
            5) echo "Exiting."; exit 0 ;;
            *) echo "Invalid option. Please try again." ;;
        esac
        break
    done
done
