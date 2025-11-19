# 🚀 START HERE - Quick Start Guide

**Get up and running with Claude Code + GitHub API in 5 minutes**

---

## ⚡ Quick Setup (First Time Only)

### Step 1: Get Your GitHub Token

1. Go to: https://github.com/settings/tokens
2. Click: **"Generate new token (classic)"**
3. Give it a name: "Claude Code Automation"
4. Select scopes:
   - ✅ `repo` (Full control of private repositories)
   - ✅ `workflow` (Update GitHub Action workflows)
   - ✅ `admin:repo_hook` (Admin access to repository hooks)
5. Click: **"Generate token"**
6. **Copy the token** (starts with `ghp_`)

### Step 2: Create Your `.env` File

```bash
cp .env.example .env
```

Edit `.env` and add your credentials:

```bash
GITHUB_TOKEN=ghp_paste_your_token_here
GITHUB_USERNAME=your_github_username
GITHUB_DEFAULT_OWNER=your_github_username
```

Save the file.

### Step 3: Test It

```bash
source .env
echo "Token loaded: ${GITHUB_TOKEN:0:10}..."
```

You should see: `Token loaded: ghp_XXXXXX...`

---

## 🎯 Using With Claude Code

### When You Open Any Project

Claude Code will **automatically read** `.claude/instructions.md` if it exists in your project.

**No need to remind it!**

### For This Template

Just ask Claude Code:

```
Create a new GitHub repository and push this code
```

Claude Code will:
1. Load your `.env` file
2. Use GitHub API with your token
3. Create the repo
4. Push the code
5. No errors, no reminders needed!

---

## 📋 Common Tasks

### Create a New Repository

**Just ask Claude Code:**

```
Create a new GitHub repository called "my-project" 
and push the initial code
```

### Create a Feature and PR

**Ask Claude Code:**

```
Create a feature branch called "add-login", 
make the changes, push it, and create a PR
```

### Merge a PR

**Ask Claude Code:**

```
Merge PR #5 to main using the GitHub API
```

---

## 🔄 Typical Workflow

**1. Make changes to code**

```
Update the authentication logic to use OAuth2
```

**2. Push and create PR**

```
Commit these changes, push to a feature branch, 
and create a PR titled "Add OAuth2 authentication"
```

**3. Merge after review**

```
Merge PR #3 to main
```

**That's it!** Claude Code handles all the GitHub API calls automatically.

---

## 📝 What Claude Code Does Automatically

When you have `.claude/instructions.md` in your project:

✅ Loads `.env` file first  
✅ Uses `$GITHUB_TOKEN` in all GitHub operations  
✅ Uses GitHub REST API for repo creation  
✅ Includes token in git push URLs  
✅ Creates PRs via API  
✅ Merges PRs via API  
✅ Follows complete workflow without reminders  

---

## 🎓 Learning the Commands

If you want to learn the actual commands Claude Code uses, check:

- **`.claude/instructions.md`** - Complete workflow guide
- **`github-api-commands.md`** - Quick command reference

But with this setup, **you don't need to know the commands** - just tell Claude Code what you want in natural language!

---

## ⚠️ Important Notes

### Security

- ✅ Never commit `.env` file (it's in `.gitignore`)
- ✅ Keep your token private
- ✅ Rotate tokens every 90 days

### Each Session

The first time you use this in a session, you might need to:

```bash
source .env
```

But Claude Code should remember to do this automatically based on `.claude/instructions.md`.

---

## 🚨 Troubleshooting

### "Permission denied" or "Authentication failed"

```bash
# Check if token is loaded
echo $GITHUB_TOKEN

# If empty or wrong, reload
source .env
```

### Claude Code not following instructions

1. Make sure `.claude/instructions.md` exists
2. Try explicitly saying: "Read the .claude/instructions.md file first"
3. Restart Claude Code session

### Token not working

1. Check token at: https://github.com/settings/tokens
2. Verify it has `repo` and `workflow` scopes
3. Generate a new token if needed
4. Update `.env` with new token

---

## 📦 Using This Template for New Projects

### Option 1: Copy the template

```bash
cp -r /path/to/claudecode-github-automation /path/to/new-project
cd /path/to/new-project
# Copy your .env file
cp /path/to/claudecode-github-automation/.env .env
```

### Option 2: Ask Claude Code

```
Create a new project with the Claude Code GitHub automation 
template, including .claude/instructions.md and .env setup
```

---

## ✅ Checklist

Before starting your first project:

- [ ] GitHub token created with correct scopes
- [ ] `.env` file created and populated
- [ ] Tested with `source .env`
- [ ] `.claude/instructions.md` present in project
- [ ] Ready to code!

---

## 🎯 Next Steps

1. **Try it out** - Create a test repository
2. **Customize** - Update `.claude/instructions.md` for your workflow
3. **Use everywhere** - Copy these files to all your projects

---

## 💡 Pro Tips

1. **Keep `.env` updated** - If you change your token, update this file
2. **Read the instructions** - `.claude/instructions.md` has the complete guide
3. **Test the API** - Use `curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user`
4. **Stay organized** - Use this template for all Claude Code projects

---

**You're all set! Start coding with Claude Code + GitHub automation! 🚀**

Need help? Check:
- `README.md` - Full documentation
- `.claude/instructions.md` - Complete workflow guide
- `github-api-commands.md` - Command reference
