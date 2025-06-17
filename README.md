
# 🛠️ GitLab Backup and Restore Documentation (With PostgreSQL Role Fixes)

## 📌 Environment

- **OS**: Ubuntu/Debian-based Linux
- **Database**: PostgreSQL (bundled with GitLab)
- **GitLab version**: Ensure version matches the backup
- **Backup File**: `/var/opt/gitlab/backups/1692339487_2025_06_17_16.9.2_gitlab_backup.tar`

---

## ✅ Step 1: Prepare Fresh VM

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl openssh-server ca-certificates tzdata perl
```

---

## ✅ Step 2: Install GitLab
Make Sure to Install The Gitlab Version Same w.r.t to the Backup Version
```bash
# Add GitLab package repo
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | sudo bash

# Install GitLab (exact same version as backup)
sudo EXTERNAL_URL="http://your-domain.com" apt install gitlab-ee=16.9.2-ee.0
```

---

## ✅ Step 3: Stop GitLab Services

```bash
sudo gitlab-ctl stop puma
sudo gitlab-ctl stop sidekiq
sudo gitlab-ctl stop
```

---

## ✅ Step 4: Place Backup File

```bash
sudo cp <your-backup>.tar /var/opt/gitlab/backups/
sudo chown git:git /var/opt/gitlab/backups/<your-backup>.tar
```

---

## ✅ Step 5: Fix PostgreSQL Roles for Extension Ownership

Before restoring, some extensions like `pg_trgm` and `btree_gist` may require the correct ownership.  
Run the following **inside the GitLab PostgreSQL shell**:

```bash
# Access GitLab PostgreSQL
sudo gitlab-psql
```

Then run:

```sql
-- List extensions and owners
SELECT extname, pg_roles.rolname AS owner
FROM pg_extension
JOIN pg_roles ON pg_extension.extowner = pg_roles.oid;

-- Change owner of extension (if needed)
ALTER EXTENSION pg_trgm OWNER TO gitlab;
ALTER EXTENSION btree_gist OWNER TO gitlab;
```

_Replace `gitlab` with actual role name if different (usually `gitlab`)_

---

## ✅ Step 6: Restore Backup

```bash
sudo gitlab-backup restore BACKUP=1692339487_2025_06_17_16.9.2_gitlab_backup
```

You may see:

```text
Do you want to continue (yes/no)? yes
```

GitLab will:
- Clean existing DB
- Restore PostgreSQL
- Restore repositories

---

## ⚠️ Known Errors (Handled)

**Sample Errors:**
```text
ERROR: cannot attach index "..." as a partition of index "..."
```

**Cause**: Partitioned index references do not match or are broken.

**Resolution**: These were safe to skip. GitLab completes restore and logs the error.

---

## ✅ Step 7: Reconfigure and Start GitLab

```bash
sudo gitlab-ctl reconfigure
sudo gitlab-ctl start
```

---

## ✅ Step 8: Verify GitLab Health

```bash
# GitLab check
sudo gitlab-rake gitlab:check SANITIZE=true

# Environment info
sudo gitlab-rake gitlab:env:info
```

---

## ✅ Optional: Reset Password (if needed)

```bash
sudo gitlab-rails console

# In console
user = User.find_by_username("root")
user.password = 'yournewpassword'
user.password_confirmation = 'yournewpassword'
user.save!
```

---

## 🔍 PostgreSQL Tools and Logs

- Connect to DB: `sudo gitlab-psql`
- Backup logs: `sudo tail -f /var/log/gitlab/gitlab-rails/backup.log`
- List backups: `ls /var/opt/gitlab/backups/`

---

## ✅ Final Check: Web UI Access

Visit: `http://<your-server-ip>`  
Login using previous credentials or use the new password if reset.
