# GitHub API Commands - Quick Reference

**Copy-paste ready commands for GitHub operations**

## ⚠️ WARNING: Git Commit Signing Fails in Web/iOS

**Use GitHub API file uploads (section below) instead of git commit/push in Web/iOS environments.**

All commands require running `source .env` first!

---

## 🔐 Prerequisites

```bash
# ALWAYS run this first
source .env

# Verify environment is loaded
echo "Token: ${GITHUB_TOKEN:0:10}..."
echo "Username: $GITHUB_USERNAME"
```

---

## 📦 Create Repository

### Basic Repository

```bash
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/user/repos \
  -d '{
    "name": "my-new-repo",
    "description": "Repository created via API",
    "private": false,
    "auto_init": true
  }'
```

### Private Repository with README

```bash
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/user/repos \
  -d '{
    "name": "my-private-repo",
    "description": "Private repository",
    "private": true,
    "auto_init": true,
    "gitignore_template": "Python",
    "license_template": "mit"
  }'
```

### Initialize Local Repo After Creation

```bash
git init
git branch -m main
git remote add origin https://$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/REPO_NAME.git

# Create initial commit
echo "# My Project" > README.md
git add .
git commit -m "Initial commit"

# Push to GitHub
git push https://$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/REPO_NAME.git main
```

---

## 📤 Upload Files via GitHub API (PRIMARY METHOD)

### Upload Single File (New File)

```bash
# Function to upload a new file
upload_new_file() {
  local file="$1"
  local repo="$2"
  local message="${3:-Add $file}"

  local content=$(base64 -w 0 "$file")

  curl -X PUT \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/repos/$GITHUB_USERNAME/$repo/contents/$file \
    -d "{
      \"message\": \"$message\",
      \"content\": \"$content\"
    }"
}

# Example usage
upload_new_file "README.md" "my-repo" "Add README file"
```

### Update Existing File

```bash
# Function to update an existing file
update_existing_file() {
  local file="$1"
  local repo="$2"
  local message="${3:-Update $file}"

  # Get current file SHA
  local sha=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    https://api.github.com/repos/$GITHUB_USERNAME/$repo/contents/$file | \
    grep '"sha"' | head -1 | cut -d'"' -f4)

  local content=$(base64 -w 0 "$file")

  curl -X PUT \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/repos/$GITHUB_USERNAME/$repo/contents/$file \
    -d "{
      \"message\": \"$message\",
      \"content\": \"$content\",
      \"sha\": \"$sha\"
    }"
}

# Example usage
update_existing_file "config.json" "my-repo" "Update configuration"
```

### Smart Upload (Handles Both New and Existing)

```bash
# Function that works for both new and existing files
smart_upload() {
  local file="$1"
  local repo="$2"
  local message="${3:-Update $file}"

  # Try to get SHA (if file exists)
  local sha=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    https://api.github.com/repos/$GITHUB_USERNAME/$repo/contents/$file 2>/dev/null | \
    grep '"sha"' | head -1 | cut -d'"' -f4)

  local content=$(base64 -w 0 "$file")

  # Build JSON based on whether SHA exists
  if [ -n "$sha" ]; then
    local json="{\"message\":\"$message\",\"content\":\"$content\",\"sha\":\"$sha\"}"
  else
    local json="{\"message\":\"$message\",\"content\":\"$content\"}"
  fi

  curl -X PUT \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/repos/$GITHUB_USERNAME/$repo/contents/$file \
    -d "$json"
}

# Example usage
smart_upload "index.html" "my-repo" "Update homepage"
```

### Bulk Upload All Files in Directory

```bash
# Function to upload all files in current directory
bulk_upload_all() {
  local repo="$1"
  local message="${2:-Bulk file upload}"
  local branch="${3:-main}"

  echo "Starting bulk upload to $repo..."

  find . -type f \
    ! -path '*/\.git/*' \
    ! -path '*/node_modules/*' \
    ! -name '.env' \
    ! -name '.DS_Store' | while read file; do

    # Remove leading ./
    local clean_path="${file#./}"
    echo "Uploading: $clean_path"

    # Get SHA if file exists
    local sha=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
      "https://api.github.com/repos/$GITHUB_USERNAME/$repo/contents/$clean_path?ref=$branch" 2>/dev/null | \
      grep '"sha"' | head -1 | cut -d'"' -f4)

    # Get base64 content
    local content=$(base64 -w 0 "$file")

    # Build JSON
    if [ -n "$sha" ]; then
      local json="{\"message\":\"$message\",\"content\":\"$content\",\"sha\":\"$sha\",\"branch\":\"$branch\"}"
    else
      local json="{\"message\":\"$message\",\"content\":\"$content\",\"branch\":\"$branch\"}"
    fi

    # Upload
    curl -s -X PUT \
      -H "Authorization: token $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github.v3+json" \
      "https://api.github.com/repos/$GITHUB_USERNAME/$repo/contents/$clean_path" \
      -d "$json" > /dev/null

    echo "✅ Uploaded: $clean_path"
    sleep 0.5  # Rate limiting
  done

  echo "Bulk upload complete!"
}

# Example usage
bulk_upload_all "my-repo" "Initial commit" "main"
```

### Upload Multiple Specific Files

```bash
# Function to upload specific files
upload_files() {
  local repo="$1"
  local message="$2"
  shift 2
  local files=("$@")

  for file in "${files[@]}"; do
    echo "Uploading $file..."
    smart_upload "$file" "$repo" "$message"
    sleep 0.3  # Rate limiting
  done
}

# Example usage
upload_files "my-repo" "Update source files" \
  "src/index.js" \
  "src/app.js" \
  "package.json" \
  "README.md"
```

### Upload to Specific Branch

```bash
# Function to upload to a specific branch
upload_to_branch() {
  local file="$1"
  local repo="$2"
  local branch="$3"
  local message="${4:-Update $file on $branch}"

  # Get SHA from specific branch
  local sha=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$GITHUB_USERNAME/$repo/contents/$file?ref=$branch" | \
    grep '"sha"' | head -1 | cut -d'"' -f4)

  local content=$(base64 -w 0 "$file")

  # Build JSON with branch
  if [ -n "$sha" ]; then
    local json="{\"message\":\"$message\",\"content\":\"$content\",\"sha\":\"$sha\",\"branch\":\"$branch\"}"
  else
    local json="{\"message\":\"$message\",\"content\":\"$content\",\"branch\":\"$branch\"}"
  fi

  curl -X PUT \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/repos/$GITHUB_USERNAME/$repo/contents/$file \
    -d "$json"
}

# Example usage
upload_to_branch "feature.js" "my-repo" "feature/new-feature" "Add feature"
```

---

## 📤 Push Code via Git (FALLBACK - May Fail in Web/iOS)

**⚠️ WARNING: Git commit signing fails in Web/iOS. Use API uploads above instead.**

### Push to Main Branch

```bash
git push https://$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/REPO_NAME.git main
```

### Push to Feature Branch

```bash
git push https://$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/REPO_NAME.git HEAD:feature-branch-name
```

### Force Push (Use Carefully!)

```bash
git push --force https://$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/REPO_NAME.git main
```

### Push with Upstream Tracking

```bash
git push -u https://$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/REPO_NAME.git main
```

---

## 🔀 Create Pull Request

### Basic PR

```bash
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/$GITHUB_USERNAME/REPO_NAME/pulls \
  -d '{
    "title": "Add new feature",
    "head": "feature-branch",
    "base": "main",
    "body": "This PR adds a new feature"
  }'
```

### PR with Detailed Description

```bash
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/$GITHUB_USERNAME/REPO_NAME/pulls \
  -d '{
    "title": "Feature: User Authentication",
    "head": "feat/auth",
    "base": "main",
    "body": "## Changes\n- Added login endpoint\n- Implemented JWT tokens\n- Added user validation\n\n## Testing\n- All tests passing\n- Manual testing completed"
  }'
```

### Create PR and Capture Number

```bash
PR_RESPONSE=$(curl -s -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/$GITHUB_USERNAME/REPO_NAME/pulls \
  -d '{
    "title": "My PR Title",
    "head": "my-branch",
    "base": "main",
    "body": "PR description"
  }')

PR_NUMBER=$(echo $PR_RESPONSE | grep -o '"number":[0-9]*' | grep -o '[0-9]*')
echo "Created PR #$PR_NUMBER"
```

---

## ✅ Merge Pull Request

### Standard Merge

```bash
curl -X PUT \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/$GITHUB_USERNAME/REPO_NAME/pulls/PR_NUMBER/merge \
  -d '{
    "merge_method": "merge"
  }'
```

### Squash and Merge

```bash
curl -X PUT \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/$GITHUB_USERNAME/REPO_NAME/pulls/PR_NUMBER/merge \
  -d '{
    "merge_method": "squash",
    "commit_title": "Feature: Add authentication",
    "commit_message": "Squashed commits from PR #5"
  }'
```

### Rebase and Merge

```bash
curl -X PUT \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/$GITHUB_USERNAME/REPO_NAME/pulls/PR_NUMBER/merge \
  -d '{
    "merge_method": "rebase"
  }'
```

---

## 🗑️ Delete Branch

### Delete Remote Branch

```bash
git push https://$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/REPO_NAME.git --delete branch-name
```

### Via API

```bash
curl -X DELETE \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/$GITHUB_USERNAME/REPO_NAME/git/refs/heads/branch-name
```

---

## 📋 List Operations

### List Repositories

```bash
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/user/repos
```

### List Pull Requests

```bash
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$GITHUB_USERNAME/REPO_NAME/pulls
```

### List Branches

```bash
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$GITHUB_USERNAME/REPO_NAME/branches
```

---

## 🔍 Check Operations

### Check PR Status

```bash
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$GITHUB_USERNAME/REPO_NAME/pulls/PR_NUMBER
```

### Check if PR is Mergeable

```bash
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$GITHUB_USERNAME/REPO_NAME/pulls/PR_NUMBER | grep mergeable
```

### Test Authentication

```bash
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/user
```

---

## 🔄 Complete Workflows

### Workflow 1: Create Repo and Push Code

```bash
# Load environment
source .env

# Create repository
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/user/repos \
  -d '{"name": "my-project", "private": false, "auto_init": false}'

# Initialize local repo
git init
git branch -m main
git remote add origin https://$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/my-project.git

# Create initial commit
echo "# My Project" > README.md
git add .
git commit -m "Initial commit"

# Push to GitHub
git push https://$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/my-project.git main
```

### Workflow 2: Feature Branch to PR to Merge

```bash
# Load environment
source .env

# Create and checkout feature branch
git checkout -b feature/new-feature

# Make changes and commit
git add .
git commit -m "Add new feature"

# Push feature branch
git push https://$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/REPO_NAME.git HEAD:feature/new-feature

# Create PR and get number
PR_RESPONSE=$(curl -s -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/$GITHUB_USERNAME/REPO_NAME/pulls \
  -d '{
    "title": "Add new feature",
    "head": "feature/new-feature",
    "base": "main",
    "body": "Description of changes"
  }')

PR_NUMBER=$(echo $PR_RESPONSE | grep -o '"number":[0-9]*' | grep -o '[0-9]*')
echo "✅ Created PR #$PR_NUMBER"

# Merge PR
curl -X PUT \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/$GITHUB_USERNAME/REPO_NAME/pulls/$PR_NUMBER/merge \
  -d '{"merge_method": "merge"}'

echo "✅ Merged PR #$PR_NUMBER"

# Delete feature branch
git push https://$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/REPO_NAME.git --delete feature/new-feature

# Checkout main and pull
git checkout main
git pull https://$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/REPO_NAME.git main
```

### Workflow 3: Quick Fix to Main

```bash
# Load environment
source .env

# Make changes and commit
git add .
git commit -m "Quick fix: Update configuration"

# Push directly to main
git push https://$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/REPO_NAME.git main
```

---

## 🛠️ Utility Commands

### Set Git Config for Token Usage

```bash
git config --local credential.helper ""
```

### Check Remote URLs

```bash
git remote -v
```

### Update Remote URL with Token

```bash
git remote set-url origin https://$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/REPO_NAME.git
```

---

## 🔧 Advanced Operations

### Create Release

```bash
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/$GITHUB_USERNAME/REPO_NAME/releases \
  -d '{
    "tag_name": "v1.0.0",
    "name": "Version 1.0.0",
    "body": "Release notes here",
    "draft": false,
    "prerelease": false
  }'
```

### Add Collaborator

```bash
curl -X PUT \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/$GITHUB_USERNAME/REPO_NAME/collaborators/COLLABORATOR_USERNAME \
  -d '{"permission": "push"}'
```

---

## 📝 Notes

- Replace `REPO_NAME` with your actual repository name
- Replace `PR_NUMBER` with actual PR number
- Replace `branch-name` with actual branch name
- Always run `source .env` first
- Check API response for errors

---

## 🚨 Troubleshooting Commands

### Check Token Validity

```bash
curl -I -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user
```

### View Token Scopes

```bash
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user | grep -i scope
```

### Test Repository Access

```bash
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$GITHUB_USERNAME/REPO_NAME
```

---

**Remember**: These are templates. Adjust repository names, branch names, and PR numbers as needed!
