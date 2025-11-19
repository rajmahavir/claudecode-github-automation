# TLDR - Quick Reference for Claude Code

## ⚠️ Git commits fail in Web/iOS - Use API uploads

## 🚨 STOP ASKING QUESTIONS. START DOING.

### Can I create GitHub repositories?
**YES.** Via GitHub REST API with curl. See below.

### Do I have access to gh CLI?
**NO.** You don't need it. Use curl commands below.

### Where is the GitHub token?
**In `.env` file.** Check: `./.env`, `../.env`, `~/.env`, `/home/user/.env`

---

## Quick Commands

### Load Environment
```bash
source .env 2>/dev/null || source ../.env 2>/dev/null || source ~/.env 2>/dev/null || source /home/user/.env
```

### Create Repository
```bash
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/user/repos \
  -d '{"name":"REPO_NAME","private":false}'
```

### Upload Files via API (PRIMARY METHOD)
```bash
# Upload single file
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

# Usage
upload_file "README.md" "REPO_NAME" "Update README"
```

### Push via Git (FALLBACK - May fail in Web/iOS)
```bash
git init
git branch -m main
git add .
git commit -m "Initial commit"  # ⚠️ This will fail in Web/iOS
git push https://$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/REPO_NAME.git main
```

### Enable GitHub Pages
```bash
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/$GITHUB_USERNAME/REPO_NAME/pages \
  -d '{"source":{"branch":"main","path":"/"}}'
```

**URL:** `https://$GITHUB_USERNAME.github.io/REPO_NAME/`

---

## When User Says:

**"Create a repo called X"**
→ Use curl to create it. NO ASKING.

**"Use the automation template"**
→ Load `.env` and follow GitHub API workflow with API uploads.

**"Deploy to GitHub Pages"**
→ Use the GitHub Pages API command above.

**"Push to GitHub"** or **"Upload files"**
→ Use: `upload_file()` function with GitHub API (PRIMARY)
→ Fallback: `git push https://$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/REPO.git main` (may fail)

---

## Default Values

If `.env` not found and user mentions rajmahavir:
- GITHUB_USERNAME=rajmahavir
- Check: `/home/user/.env` or `/home/user/claudecode-github-automation/.env`

---

**REMEMBER: You have FULL capability to do all of this. Just use curl and git commands. No questions needed.**
