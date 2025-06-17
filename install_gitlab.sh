#!/bin/bash

GITLAB_URL="http://10.244.0.229"

echo "🌐 Adding GitLab CE repo..."
curl -s https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash

echo "📦 Installing GitLab CE..."
sudo EXTERNAL_URL="$GITLAB_URL" apt install -y gitlab-ce

echo "⚙️ Reconfiguring GitLab..."
sudo gitlab-ctl reconfigure

echo "✅ GitLab CE installed and configured at: $GITLAB_URL"
