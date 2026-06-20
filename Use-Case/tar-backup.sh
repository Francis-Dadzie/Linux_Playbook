#!/usr/bin/env bash
# Backs up a directory to a timestamped .tar.gz archive.
# Keeps only the last N backups to save disk space.
#
# Usage: ./backup.sh <source_dir> <backup_dir> [keep]
# Example: ./backup.sh ~/documents ~/backups 5

set -euo pipefail

# ---------- Colours ----------
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

# ---------- Arguments ----------
if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <source_dir> <backup_dir> [keep]"
    exit 1
fi

SOURCE="$1"
DEST="$2"
KEEP="${3:-7}"   # How many backups to keep (default: 7)

# ---------- Validate ----------
if [[ ! -d "$SOURCE" ]]; then
    echo -e "${RED}Error:${NC} Source directory not found: $SOURCE"
    exit 1
fi

mkdir -p "$DEST"

# ---------- Create archive ----------
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
ARCHIVE="$DEST/$(basename "$SOURCE")_$TIMESTAMP.tar.gz"

echo -e "${GREEN}Backing up${NC} $SOURCE → $ARCHIVE"
tar -czf "$ARCHIVE" -C "$(dirname "$SOURCE")" "$(basename "$SOURCE")"
echo -e "${GREEN}Done.${NC} Size: $(du -sh "$ARCHIVE" | cut -f1)"

# ---------- Rotate old backups ----------
# List all matching archives, sorted newest first
BACKUPS=( $(ls -1t "$DEST"/$(basename "$SOURCE")_*.tar.gz 2>/dev/null) )

if [[ ${#BACKUPS[@]} -gt $KEEP ]]; then
    echo -e "${YELLOW}Rotating old backups (keeping $KEEP)...${NC}"
    # Everything after index $KEEP is old — delete it
    for OLD in "${BACKUPS[@]:$KEEP}"; do
        echo "  Removing: $(basename "$OLD")"
        rm -f "$OLD"
    done
fi

echo "Backups kept: $(ls -1 "$DEST"/$(basename "$SOURCE")_*.tar.gz 2>/dev/null | wc -l)"
