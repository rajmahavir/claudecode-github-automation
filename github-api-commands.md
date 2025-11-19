# GitHub API Commands - Quick Reference

**Copy-paste ready commands for GitHub operations**

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

## 📤 Push Code

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
