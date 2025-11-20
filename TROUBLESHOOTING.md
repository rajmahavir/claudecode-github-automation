# Troubleshooting Guide

## Common Issues and Solutions for Claude Code GitHub Automation

---

## 🚨 Git Commit Signing Failures (Web/iOS)

### Error Message

```
error: signing failed: signing operation failed
fatal: failed to write commit object
```

or

```
error: gpg failed to sign the data
fatal: failed to write commit object
```

### Root Cause

Claude Code Web/iOS environments do not support GPG/SSH commit signing. When git tries to create a commit, it fails during the signing process.

### ❌ What Does NOT Work

1. **Disabling commit signing:**
   ```bash
   git config --global commit.gpgsign false  # Does NOT work
   ```

2. **Configuring GPG:**
   ```bash
   git config --global gpg.program gpg2  # Does NOT work
   ```

3. **Using --no-gpg-sign:**
   ```bash
   git commit --no-gpg-sign -m "message"  # Does NOT work
   ```

4. **Any git commit command** - None of them work in Web/iOS

### ✅ Solution: Use GitHub API File Uploads

Instead of using `git commit` and `git push`, upload files directly via GitHub API.

#### Quick Solution

```bash
# Environment variables are already available

# Function to upload files
upload_file() {
  local file="$1"
  local repo="$2"
  local message="${3:-Update $file}"

  # Get SHA if file exists
  local sha=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    https://api.github.com/repos/$GITHUB_USERNAME/$repo/contents/$file | \
    grep '"sha"' | head -1 | cut -d'"' -f4)

  # Get base64 content
  local content=$(base64 -w 0 "$file")

  # Upload
  if [ -n "$sha" ]; then
    curl -X PUT -H "Authorization: token $GITHUB_TOKEN" \
      https://api.github.com/repos/$GITHUB_USERNAME/$repo/contents/$file \
      -d "{\"message\":\"$message\",\"content\":\"$content\",\"sha\":\"$sha\"}"
  else
    curl -X PUT -H "Authorization: token $GITHUB_TOKEN" \
      https://api.github.com/repos/$GITHUB_USERNAME/$repo/contents/$file \
      -d "{\"message\":\"$message\",\"content\":\"$content\"}"
  fi
}

# Upload your files
upload_file "README.md" "my-repo" "Update README"
upload_file "src/app.js" "my-repo" "Update app"
```

#### Bulk Upload Solution

Use the script at `scripts/upload-to-github.sh`:

```bash
# Environment variables are already available
./scripts/upload-to-github.sh claudecode-github-automation "Update all files"
```

---

## 🔒 Authentication Errors

### Error: "Bad credentials"

```json
{
  "message": "Bad credentials",
  "documentation_url": "https://docs.github.com/rest"
}
```

#### Causes

1. Environment variables not set in Claude Code Settings
2. Token is expired or invalid
3. Token has wrong format

#### Solutions

```bash
# 1. Check if token is loaded
echo $GITHUB_TOKEN
# Should show: ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# 2. If empty, set in Claude Code Settings → Environment Variables

# 3. Verify token format
echo ${GITHUB_TOKEN:0:4}
# Should show: ghp_

# 4. Test token validity
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user
# Should return your user info, not an error
```

#### Fix

```bash
# Environment variables should already be available
# Verify they're set
echo "Token: ${GITHUB_TOKEN:0:10}..."
echo "Username: $GITHUB_USERNAME"
```

---

## 📁 File Upload Errors

### Error: "422 Unprocessable Entity"

```json
{
  "message": "Invalid request.\n\n\"sha\" wasn't supplied."
}
```

#### Cause

File already exists on GitHub but you didn't provide the SHA hash.

#### Solution

Always get the SHA first before updating:

```bash
# Get the file's current SHA
sha=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$GITHUB_USERNAME/REPO/contents/FILE.md | \
  grep '"sha"' | head -1 | cut -d'"' -f4)

# Include SHA in update
curl -X PUT \
  -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$GITHUB_USERNAME/REPO/contents/FILE.md \
  -d "{\"message\":\"Update\",\"content\":\"$content\",\"sha\":\"$sha\"}"
```

Or use the `smart_upload` function from `github-api-commands.md` which handles this automatically.

---

### Error: "404 Not Found"

```json
{
  "message": "Not Found"
}
```

#### Causes

1. Repository doesn't exist
2. Token doesn't have access to the repository
3. Wrong repository name or username
4. File path is incorrect

#### Solutions

```bash
# 1. Verify repository exists
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$GITHUB_USERNAME/REPO_NAME

# 2. List your repositories
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/user/repos | grep '"name"'

# 3. Check environment variables
echo "Username: $GITHUB_USERNAME"
echo "Repo: REPO_NAME"

# 4. Verify token permissions
# Token needs 'repo' scope for private repos
```

---

## 🔄 Pull Request Errors

### Error: "No commits between main and branch"

```json
{
  "message": "No commits between main and feature-branch"
}
```

#### Cause

The feature branch has no new commits compared to the base branch.

#### Solution

Ensure your branch has commits:

```bash
# Check if branch has unique commits
git log main..feature-branch

# If empty, make changes and create commits
# Then upload via API instead of git push
```

---

### Error: "A pull request already exists"

```json
{
  "message": "A pull request already exists for username:branch"
}
```

#### Solution

1. List existing PRs:
   ```bash
   curl -H "Authorization: token $GITHUB_TOKEN" \
     https://api.github.com/repos/$GITHUB_USERNAME/REPO/pulls
   ```

2. Either update the existing PR or close it first

---

## 🌐 GitHub Pages Errors

### Error: "GitHub Pages is disabled"

#### Solution

Enable it via API:

```bash
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$GITHUB_USERNAME/REPO/pages \
  -d '{"source":{"branch":"main","path":"/"}}'
```

---

### Error: "Source is not supported"

#### Cause

Trying to use an unsupported branch or path.

#### Solution

Use only:
- Branch: `main`, `master`, or `gh-pages`
- Path: `/` or `/docs`

```bash
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$GITHUB_USERNAME/REPO/pages \
  -d '{"source":{"branch":"main","path":"/"}}'
```

---

## 🔑 Token Permission Errors

### Error: "Resource not accessible by personal access token"

```json
{
  "message": "Resource not accessible by personal access token"
}
```

#### Cause

Token is missing required scopes/permissions.

#### Required Scopes

For full functionality, your token needs:
- `repo` - Full control of private repositories
- `workflow` - Update GitHub Action workflows
- `admin:repo_hook` - Full control of repository hooks

#### Solution

1. Go to: https://github.com/settings/tokens
2. Generate new token with required scopes
3. Update `.env` file with new token
4. Reload environment: `source .env`

---

## 📊 Rate Limiting

### Error: "API rate limit exceeded"

```json
{
  "message": "API rate limit exceeded for user ID xxx"
}
```

#### Cause

GitHub API limits:
- Authenticated requests: 5,000 per hour
- File uploads: Recommended 1-2 per second

#### Solution

Add delays between requests:

```bash
# In loops, add sleep
for file in *.md; do
  upload_file "$file" "my-repo"
  sleep 0.5  # Wait 500ms between uploads
done
```

The `bulk_upload_all` function in `github-api-commands.md` already includes rate limiting.

---

## 🛠️ Base64 Encoding Issues

### Error: Content appears corrupted after upload

#### Cause

Using `base64` with line wrapping (default 76 chars per line).

#### Solution

Always use `-w 0` flag:

```bash
# ❌ Wrong
content=$(base64 file.txt)

# ✅ Correct
content=$(base64 -w 0 file.txt)
```

---

## 🔍 Debugging Tips

### Enable Verbose curl Output

```bash
# Add -v flag to see full request/response
curl -v -X PUT \
  -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$GITHUB_USERNAME/REPO/contents/file.txt \
  -d "{...}"
```

### Check API Response

```bash
# Save response to file
response=$(curl -s -X PUT \
  -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$GITHUB_USERNAME/REPO/contents/file.txt \
  -d "{...}")

# Print response
echo "$response" | jq .  # Pretty print JSON
# or
echo "$response"  # Raw output
```

### Verify Environment Variables

```bash
# Check all required variables
echo "GITHUB_TOKEN: ${GITHUB_TOKEN:0:10}..."
echo "GITHUB_USERNAME: $GITHUB_USERNAME"
echo "GITHUB_DEFAULT_OWNER: $GITHUB_DEFAULT_OWNER"

# Test API access
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user
```

---

## 📚 Additional Resources

- **GitHub API Docs:** https://docs.github.com/rest
- **GitHub API Commands:** See `github-api-commands.md`
- **Complete Instructions:** See `.claude/instructions.md`
- **Quick Reference:** See `TLDR.md`

---

## 🆘 Still Having Issues?

1. Check that you've run `source .env`
2. Verify your token has correct permissions
3. Test with a simple API call: `curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user`
4. Review the error message carefully - it usually tells you exactly what's wrong
5. Try the `smart_upload` function which handles most edge cases automatically

---

**Remember:** In Web/iOS environments, ALWAYS use GitHub API uploads instead of git commit/push.
