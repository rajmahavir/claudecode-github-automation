# Claude Code - GitHub API Automation Instructions

## ⚠️ CRITICAL WARNING: Git Commit Signing Failures in Web/iOS

**Git commits will FAIL in Claude Code Web/iOS environment with "signing failed: signing operation failed" error.**

**SOLUTION: Use GitHub API file uploads as PRIMARY method (not git commit/push).**

---

## 🚨 CRITICAL: Environment Variables Are Already Available

**NEVER try to load .env files. Environment variables are already available in Claude Code Web/iOS.**

**Just use them directly with `$GITHUB_TOKEN` or `$GITHUB_USERNAME` in bash scripts.**

---

## Environment Variables

The following environment variables are already set in your Claude Code environment:

- `GITHUB_TOKEN` - Your GitHub Personal Access Token (with repo, workflow, admin:repo_hook scopes)
- `GITHUB_USERNAME` - Your GitHub username
- `GITHUB_DEFAULT_OWNER` - Default owner for repositories (usually same as username)

**DO NOT use `# Environment variables are already available` or try to load environment variables. They are ALREADY available.**

---

## GitHub Operations Workflow

### 1. Creating a New Repository

**ALWAYS use GitHub REST API:**

```bash
# Environment variables are already available - just use them directly
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/user/repos \
  -d '{
    "name": "repository-name",
    "description": "Repository description",
    "private": false,
    "auto_init": true
  }'
```

**After creating, initialize local repo:**

```bash
git init
git branch -m main
git remote add origin https://$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/repository-name.git
```

---

### 2. Uploading Files to GitHub (PRIMARY METHOD)

**⚠️ In Web/iOS environments, git commit signing fails. Use GitHub API uploads instead.**

#### Upload a Single File

```bash
# Environment variables are already available

# Function to upload a file via GitHub API
upload_file() {
  local file="$1"
  local repo="$2"
  local message="${3:-Update $file}"

  # Get base64 content (remove line wrapping with -w 0)
  local content=$(base64 -w 0 "$file")

  # Upload via GitHub API
  curl -X PUT \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/repos/$GITHUB_USERNAME/$repo/contents/$file \
    -d "{\"message\":\"$message\",\"content\":\"$content\"}"
}

# Example usage
upload_file "README.md" "my-repo" "Update README"
```

#### Update Existing File

```bash
# Environment variables are already available

# Function to update existing file (requires SHA)
update_file() {
  local file="$1"
  local repo="$2"
  local message="${3:-Update $file}"

  # Get current file SHA
  local sha=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    https://api.github.com/repos/$GITHUB_USERNAME/$repo/contents/$file | \
    grep '"sha"' | head -1 | cut -d'"' -f4)

  # Get base64 content
  local content=$(base64 -w 0 "$file")

  # Update via GitHub API
  curl -X PUT \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/repos/$GITHUB_USERNAME/$repo/contents/$file \
    -d "{\"message\":\"$message\",\"content\":\"$content\",\"sha\":\"$sha\"}"
}

# Example usage
update_file "config.json" "my-repo" "Update configuration"
```

#### Bulk Upload Multiple Files

```bash
# Environment variables are already available

# Function to upload all files in directory
bulk_upload() {
  local repo="$1"
  local message="${2:-Bulk file upload}"

  find . -type f ! -path '*/\.git/*' ! -name '.env' | while read file; do
    # Remove leading ./
    local clean_path="${file#./}"
    echo "Uploading $clean_path..."

    # Get base64 content
    local content=$(base64 -w 0 "$file")

    # Try to get SHA (if file exists)
    local sha=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
      https://api.github.com/repos/$GITHUB_USERNAME/$repo/contents/$clean_path 2>/dev/null | \
      grep '"sha"' | head -1 | cut -d'"' -f4)

    # Upload with or without SHA
    if [ -n "$sha" ]; then
      curl -X PUT \
        -H "Authorization: token $GITHUB_TOKEN" \
        https://api.github.com/repos/$GITHUB_USERNAME/$repo/contents/$clean_path \
        -d "{\"message\":\"$message\",\"content\":\"$content\",\"sha\":\"$sha\"}"
    else
      curl -X PUT \
        -H "Authorization: token $GITHUB_TOKEN" \
        https://api.github.com/repos/$GITHUB_USERNAME/$repo/contents/$clean_path \
        -d "{\"message\":\"$message\",\"content\":\"$content\"}"
    fi

    sleep 0.5  # Rate limiting
  done
}

# Example usage
bulk_upload "my-repo" "Initial file upload"
```

---

### 3. Pushing Code via Git (FALLBACK - May fail in Web/iOS)

**⚠️ WARNING: This method requires git commit signing which FAILS in Web/iOS.**

**Only use if you're in a desktop environment where git signing works.**

```bash
# Environment variables are already available

# Push to main
git push https://$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/REPO_NAME.git main

# Push to branch
git push https://$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/REPO_NAME.git HEAD:branch-name

# Force push (use carefully)
git push --force https://$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/REPO_NAME.git main
```

---

### 4. Creating a Pull Request

**Use GitHub REST API:**

```bash
# Environment variables are already available

# Get the PR creation response
PR_RESPONSE=$(curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/$GITHUB_USERNAME/REPO_NAME/pulls \
  -d '{
    "title": "Pull Request Title",
    "head": "feature-branch",
    "base": "main",
    "body": "Description of changes"
  }')

# Extract PR number
PR_NUMBER=$(echo $PR_RESPONSE | grep -o '"number":[0-9]*' | grep -o '[0-9]*')
echo "Created PR #$PR_NUMBER"
```

---

### 5. Merging a Pull Request

**Use GitHub REST API with the PR number:**

```bash
# Environment variables are already available

curl -X PUT \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/$GITHUB_USERNAME/REPO_NAME/pulls/PR_NUMBER/merge \
  -d '{
    "merge_method": "merge",
    "commit_title": "Merge PR #PR_NUMBER",
    "commit_message": "Merged via GitHub API"
  }'
```

**Available merge methods:**
- `merge` - Standard merge commit
- `squash` - Squash and merge
- `rebase` - Rebase and merge

---

### 6. Complete Workflow Example

**Full workflow using API uploads (recommended for Web/iOS):**

```bash
# Step 1: Load environment
# Environment variables are already available

# Step 2: Make your code changes (edit files as needed)

# Step 3: Upload changed files via API
# Upload single files
upload_file() {
  local file="$1"
  local repo="$2"
  local branch="${3:-main}"
  local message="${4:-Update $file}"

  # Get current file SHA if it exists
  local sha=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$GITHUB_USERNAME/$repo/contents/$file?ref=$branch" | \
    grep '"sha"' | head -1 | cut -d'"' -f4)

  # Get base64 content
  local content=$(base64 -w 0 "$file")

  # Build JSON payload
  if [ -n "$sha" ]; then
    local json="{\"message\":\"$message\",\"content\":\"$content\",\"sha\":\"$sha\",\"branch\":\"$branch\"}"
  else
    local json="{\"message\":\"$message\",\"content\":\"$content\",\"branch\":\"$branch\"}"
  fi

  # Upload
  curl -X PUT \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/$GITHUB_USERNAME/$repo/contents/$file" \
    -d "$json"
}

# Example: Upload files directly to main
upload_file "src/app.js" "my-repo" "main" "Add new feature"
upload_file "README.md" "my-repo" "main" "Update documentation"

echo "✅ Files uploaded successfully"
```

**Alternative: Traditional git workflow (if signing works):**

```bash
# Step 1: Load environment
# Environment variables are already available

# Step 2: Create and switch to feature branch (local only)
git checkout -b feature/new-feature

# Step 3: Make changes, then commit (local only)
git add .
git commit -m "Add new feature"

# Step 4: Upload files via API instead of git push
# (See bulk_upload function in section 2)

# Step 5: Create Pull Request
PR_RESPONSE=$(curl -s -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/$GITHUB_USERNAME/REPO_NAME/pulls \
  -d '{
    "title": "Add new feature",
    "head": "feature/new-feature",
    "base": "main",
    "body": "This PR adds a new feature with the following changes:\n- Change 1\n- Change 2"
  }')

PR_NUMBER=$(echo $PR_RESPONSE | grep -o '"number":[0-9]*' | grep -o '[0-9]*')
echo "✅ Created PR #$PR_NUMBER"

# Step 6: Merge the PR (after review/approval)
curl -X PUT \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/$GITHUB_USERNAME/REPO_NAME/pulls/$PR_NUMBER/merge \
  -d '{"merge_method": "merge"}'

echo "✅ Merged PR #$PR_NUMBER"
```

---

## ❌ NEVER DO These Things

1. **NEVER** rely on `git commit` in Web/iOS environments (signing fails)
2. **NEVER** use `git push` without the token in the URL (if using git at all)
3. **NEVER** try to load .env files - environment variables are already available
4. **NEVER** use `gh` CLI commands (not available in Web/iOS)
5. **NEVER** try to setup git credential helpers or signing configs
6. **NEVER** hardcode tokens in commands
7. **NEVER** use dotenv, python-dotenv, or any .env loading libraries

---

## ✅ ALWAYS DO These Things

1. **ALWAYS** use environment variables directly - they are already available
2. **ALWAYS** use GitHub API file uploads as PRIMARY method in Web/iOS
3. **ALWAYS** use `$GITHUB_TOKEN` and `$GITHUB_USERNAME` variables in commands
4. **ALWAYS** use GitHub REST API for PR creation and merging
5. **ALWAYS** access environment variables with `$VAR_NAME` in bash or `process.env.VAR_NAME` in Node.js or `os.environ.get('VAR_NAME')` in Python
6. **ALWAYS** follow the complete workflow steps in order
7. **ALWAYS** use API uploads instead of git push when in Web/iOS

---

## Verification Commands

**Check if environment variables are available:**

```bash
echo "Token: ${GITHUB_TOKEN:0:10}..."
echo "Username: $GITHUB_USERNAME"
```

**Test GitHub API access:**

```bash
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user
```

---

## Quick Reference Scripts

See `github-api-commands.md` for copy-paste ready commands.

---

## Troubleshooting

**If git commit fails with "signing failed: signing operation failed":**
- This is EXPECTED in Web/iOS environments
- **SOLUTION:** Use GitHub API file uploads instead (see section 2)
- Do NOT try to configure git signing - it won't work
- Use the `upload_file()` or `bulk_upload()` functions instead

**If push fails with authentication error:**
- Verify: `echo $GITHUB_TOKEN` (should show token)
- If empty, environment variables are not set correctly in Claude Code settings
- Check token has correct permissions on GitHub

**If API calls fail:**
- Verify token format: `ghp_` followed by 36 characters
- Check token scopes include: `repo`, `workflow`
- Test with: `curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user`

**If file upload fails with "422 Unprocessable Entity":**
- File already exists - you need to provide the SHA
- Use `update_file()` function instead of `upload_file()`
- Or use the bulk_upload function which handles both cases

**If PR creation fails:**
- Ensure branch exists on remote
- Verify base branch name (main vs master)
- Check branch has commits that differ from base

---

## Security Notes

- Environment variables are stored securely in Claude Code settings
- Token should have minimum required permissions
- Rotate tokens periodically
- Never share token in logs or outputs
- Never commit tokens to repository

---

**Remember:** Environment variables are already available. Just use them directly with `$VAR_NAME`, `process.env.VAR_NAME`, or `os.environ.get('VAR_NAME')`.
