#!/bin/bash
# GitLab Restore Script

echo "Starting GitLab Restore..."

# Define backup file name (change accordingly)
BACKUP_TIMESTAMP="YOUR_BACKUP_TIMESTAMP"  # e.g., 1687177714_2024_06_15
BACKUP_FILE="$BACKUP_TIMESTAMP_gitlab_backup.tar"

# Stop GitLab services before restoring
gitlab-ctl stop puma
gitlab-ctl stop sidekiq

# (Optional) Restore configuration and secrets if available
# cp /backup/location/gitlab.rb /etc/gitlab/gitlab.rb
# cp /backup/location/gitlab-secrets.json /etc/gitlab/gitlab-secrets.json

# Place backup file in correct location
cp /backup/location/$BACKUP_FILE /var/opt/gitlab/backups/
chown git:git /var/opt/gitlab/backups/$BACKUP_FILE

# Restore the backup
gitlab-backup restore BACKUP=$BACKUP_TIMESTAMP

# Fix PostgreSQL roles/ownership (if needed)
sudo gitlab-psql -d gitlabhq_production -c "
DO \$\$
DECLARE
    ext RECORD;
BEGIN
    FOR ext IN SELECT extname FROM pg_extension LOOP
        EXECUTE format('ALTER EXTENSION %I OWNER TO gitlab;', ext.extname);
    END LOOP;
END
\$\$;
"

# Start GitLab services again
gitlab-ctl start

# Reconfigure if needed
gitlab-ctl reconfigure

echo "GitLab restore completed."
