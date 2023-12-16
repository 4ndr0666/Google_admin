#!/bin/bash

# Configuration
RCLONE_CONFIG="/home/andro/.config/rclone/rclone.conf"
DOWNLOAD_DIR="/Nas2/Gdrive/Picture Takeout"
UPLOAD_DIR="/Nas2/Gdrive/Google Photos"
DRIVE_NAME="google-drive" # Replace with your Google Drive name in rclone config
TRASH_DIR="/Nas2/Gdrive/Picture Takeout/Trash"

# Check for required tools
REQUIRED_TOOLS=("rclone" "tar" "unzip" "jdupes")
for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
        echo "Error: Required tool $tool is not installed."
        exit 1
    fi
done

# Function to handle file extraction
extract_files() {
    echo "Extracting files..."
    find "$DOWNLOAD_DIR" \( -name "*.tgz" -o -name "*.zip" \) -print0 | while IFS= read -r -d '' file; do
        case "$file" in
            *.tgz)
                echo "Extracting $file..."
                if ! tar -xzf "$file" -C "$UPLOAD_DIR"; then
                    echo "Error extracting $file" >> error.log
                    continue
                fi
                ;;
            *.zip)
                echo "Extracting $file..."
                if ! unzip -o "$file" -d "$UPLOAD_DIR"; then
                    echo "Error extracting $file" >> error.log
                    continue
                fi
                ;;
        esac
        echo "Moving $file to trash..."
        if ! mv "$file" "$TRASH_DIR"; then
            echo "Error moving $file to trash" >> error.log
        fi
    done
    echo "Extraction complete."
}

# Function to deduplicate files using jdupes
deduplicate_files() {
    echo "Deduplicating files in $UPLOAD_DIR..."
    jdupes -r "$UPLOAD_DIR" -o name -A -s -N --linkhard -m "$TRASH_DIR"
    echo "Deduplication complete."
}

# --- // DELETES_DUPES_PERMANENTLY // ========
# Function to deduplicate files using jdupes
#deduplicate_files() {
#    echo "Deduplicating files in $UPLOAD_DIR..."
#    jdupes -r "$UPLOAD_DIR" -o name -A -s -N -d
#    echo "Deduplication complete."
#}


# Main process
echo "Starting Google Photos cleanup process..."
mkdir -p "$TRASH_DIR"
extract_files
deduplicate_files

# Upload the processed files back to Google Drive
echo "Uploading processed files back to Google Drive..."
if rclone --config "$RCLONE_CONFIG" copy "$UPLOAD_DIR" "$DRIVE_NAME:/Google Photos" --ignore-existing --timeout 1h
--drive-chunk-size 64M --tpslimit 10 --retries 3; then
    echo "Drive cleanup process completed."
else
    echo "Error in uploading files."
    exit 1
fi
