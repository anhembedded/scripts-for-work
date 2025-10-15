#!/bin/bash

# Example: Automated Cleanup Script
# This script demonstrates cleaning up old files

# Source the logger library
source "$(dirname "$0")/../lib/logger.sh"

# Configuration
CLEANUP_DIR="${1:-/tmp}"
DAYS_OLD="${2:-30}"

log_info "Starting cleanup process"
log_info "Directory: $CLEANUP_DIR"
log_info "Removing files older than $DAYS_OLD days"

# Check if directory exists
if [ ! -d "$CLEANUP_DIR" ]; then
    log_error "Directory does not exist: $CLEANUP_DIR"
    exit 1
fi

# Find and remove old files
count=0
while IFS= read -r -d '' file; do
    log_info "Removing: $file"
    rm -f "$file"
    ((count++))
done < <(find "$CLEANUP_DIR" -type f -mtime "+$DAYS_OLD" -print0)

log_info "Cleanup completed. Removed $count files"
