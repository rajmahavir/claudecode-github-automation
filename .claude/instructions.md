# Claude Code - GitHub API Automation Instructions

## 🚨 CRITICAL: Read This First for EVERY Session

This project uses GitHub Personal Access Token stored in `.env` file for ALL GitHub operations.

---

## Mandatory First Step - ALWAYS Execute

**Before ANY GitHub operation, ALWAYS run:**

```bash
source .env
```

This loads your `GITHUB_TOKEN` and other GitHub credentials into the environment.

---

## Environment Variables

The following variables MUST be present in `.env`:

- `GITHUB_TOKEN` - Your GitHub Personal Access Token (with repo, workflow, admin:repo_hook scopes)
- `GITHUB_USERNAME` - Your GitHub username
- `GITHUB_DEFAULT_OWNER` - Default owner for repositories (usually same as username)

---

## GitHub Operations Workflow

### 1. Creating a New Repository

**ALWAYS use GitHub REST API:**

```bash
source .env

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

### 2. Pushing Code to GitHub

**NEVER use plain `git push`. ALWAYS include token in URL:**

```bash
source .env

# Push to main
git push https://$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/REPO_NAME.git main

# Push to branch
git push https://$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/REPO_NAME.git HEAD:branch-name

# Force push (use carefully)
git push --force https://$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/REPO_NAME.git main
```

---

### 3. Creating a Pull Request

**Use GitHub REST API:**

```bash
source .env

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

### 4. Merging a Pull Request

**Use GitHub REST API with the PR number:**

```bash
source .env

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

### 5. Complete Workflow Example

**Full workflow from code changes to merged PR:**

```bash
# Step 1: Load environment
source .env

# Step 2: Create and switch to feature branch
git checkout -b feature/new-feature

# Step 3: Make changes, then commit
git add .
git commit -m "Add new feature"

# Step 4: Push branch to GitHub
git push https://$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/REPO_NAME.git HEAD:feature/new-feature

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

# Step 7: Delete remote branch (optional)
git push https://$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/REPO_NAME.git --delete feature/new-feature

# Step 8: Switch back to main and pull
git checkout main
git pull https://$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/REPO_NAME.git main
```

---

## ❌ NEVER DO These Things

1. **NEVER** use `git push` without the token in the URL
2. **NEVER** skip `source .env` at the beginning
3. **NEVER** use `gh` CLI commands (not available in Web/iOS)
4. **NEVER** try to setup git credential helpers
5. **NEVER** hardcode tokens in commands
6. **NEVER** forget to load environment variables before API calls

---

## ✅ ALWAYS DO These Things

1. **ALWAYS** run `source .env` as the first command
2. **ALWAYS** use `$GITHUB_TOKEN` variable in commands
3. **ALWAYS** include token in git push URLs: `https://$GITHUB_TOKEN@github.com/...`
4. **ALWAYS** use GitHub REST API for PR creation and merging
5. **ALWAYS** verify environment variables are loaded before proceeding
6. **ALWAYS** follow the complete workflow steps in order

---

## Verification Commands

**Check if environment is loaded:**

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

**If push fails with authentication error:**
- Verify: `echo $GITHUB_TOKEN` (should show token)
- If empty, run: `source .env`
- Check token has correct permissions on GitHub

**If API calls fail:**
- Verify token format: `ghp_` followed by 36 characters
- Check token scopes include: `repo`, `workflow`
- Test with: `curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user`

**If PR creation fails:**
- Ensure branch exists on remote
- Verify base branch name (main vs master)
- Check branch has commits that differ from base

---

## Security Notes

- Never commit `.env` file to repository (it's in `.gitignore`)
- Token should have minimum required permissions
- Rotate tokens periodically
- Never share token in logs or outputs

---

**Remember:** The `.env` file is the single source of truth for GitHub credentials. Load it first, use it always.
