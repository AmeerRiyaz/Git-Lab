#!/bin/bash
# GitLab Backup Script

echo "Starting GitLab Backup..."

# Set timestamp and backup directory
TIMESTAMP=$(date +%Y%m%d%H%M)
BACKUP_DIR="/var/opt/gitlab/backups"

# Trigger GitLab backup
gitlab-backup create STRATEGY=copy

# Set permissions (optional but recommended)
chown git:git $BACKUP_DIR/*.tar
chmod 600 $BACKUP_DIR/*.tar

echo "GitLab backup completed. Backup file stored at: $BACKUP_DIR"
