# Google Drive Management with Rclone

This guide shows you how to use command-line `rclone` to manage your Google Drive. This includes tasks such as
extracting Google Takeout archives, organizing files, backing up important directories, and deduplicating files.

## Prerequisites

- `rclone` installed on your system. You can download it from [here](https://rclone.org/downloads/).
- A Google Drive configured in `rclone`. Follow the instructions [here](https://rclone.org/drive/) to set it up.

## Quick Start

The `cht.sh` and `tldr` commands provide concise instructions for many common tasks. Here are some examples:

- To copy files from your local system to Google Drive: `cht.sh rclone copy`
- To sync a local directory with a directory on Google Drive: `tldr rclone sync`
- To list all files in a directory on Google Drive: `cht.sh rclone ls`
- To move files from one directory to another on Google Drive: `tldr rclone move`

## Extracting Google Takeout Archives

1. Download your Google Takeout archives to a local directory.

2. Use the `tar` command to extract the archives:

```bash
tar -xvf /path/to/archive.tar.gz -C /path/to/extract/to
```

Replace `/path/to/archive.tar.gz` with the path to your archive and `/path/to/extract/to` with the directory where
you want to extract the files.

## Organizing Files by Type and Date

Use the `find` and `mv` commands to organize your files. Here's a script that organizes files by type and last
modification date:

```bash
#!/bin/bash

BASE_DIR="/path/to/your/files"

find "$BASE_DIR" -type f | while read -r file; do
    # Get the file's extension and last modification date
    ext="${file##*.}"
    date=$(date -r "$file" "+%Y-%m-%d")

    # Create the target directory
    target_dir="$BASE_DIR/$ext/$date"
    mkdir -p "$target_dir"

    # Move the file
    mv "$file" "$target_dir"
done
```

Replace `/path/to/your/files` with the path to your files.

## Backing Up Important Directories

# command to backup directories to Google Drive:

rclone copy /path/to/your/directory remote:backup_directory

# Replace `/path/to/your/directory` with the path to the directory you want to backup.
# Replace `remote:backup_directory` with the name of your Google Drive remote followed by `:`, and the name of the
backup directory.

## Deduplicating Files

You can use `rclone dedupe` to find and delete duplicate files on Google Drive:

rclone dedupe remote:directory --dedupe-mode newest

# Replace `remote:directory` with the name of your Google Drive remote followed by `:`, and the name of the
directory you want to deduplicate.

# The `--dedupe-mode newest` option tells `rclone` to keep the newest version of each file and delete the others.
You can replace `newest` with `oldest` or `rename` to keep the oldest version or rename duplicates, respectively.

## Troubleshooting

If you encounter errors while using `rclone`, here are some steps you can take:

- Check the `rclone` documentation for information about the error.
- Use the `--verbose` option with `rclone` commands to get more detailed output.
- Check your internet connection and make sure you have enough disk space.
- Make sure you're using the latest version of `rclone`.

## Conclusion

With `rclone`, you can easily manage your Google Drive from the command line. This includes extracting Google
Takeout archives, organizing files, backing up important directories, and deduplicating files. Remember to replace
the paths and names in the examples with your actual paths and names.
