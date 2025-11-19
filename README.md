# Claude Code GitHub Automation Template

🤖 **A complete template for using Claude Code (Web/iOS) with GitHub API automation**

This repository provides a comprehensive setup for Claude Code to automatically use GitHub API with your Personal Access Token, eliminating the need to repeatedly remind it about authentication.

---

## 🎯 Purpose

When using Claude Code on Web or iOS, it often ignores environment variables and tries to use git commands without proper authentication, wasting tokens on errors. This template solves that problem by providing:

- ✅ Persistent instructions that Claude Code reads automatically
- ✅ Complete GitHub API workflow templates
- ✅ Environment variable management
- ✅ Ready-to-use command references
- ✅ Proper authentication handling

---

## 📁 What's Included

- **`.claude/instructions.md`** - Core instructions Claude Code follows automatically
- **`README.md`** - This file, project overview and setup
- **`START_HERE.md`** - Quick start guide for immediate use
- **`github-api-commands.md`** - Copy-paste ready API commands
- **`.env.example`** - Template for your environment variables
- **`scripts/init-session.sh`** - Session initialization script
- **`.gitignore`** - Properly configured to exclude sensitive files

---

## 🚀 Quick Setup

### 1. Clone This Repository

```bash
git clone https://github.com/YOUR_USERNAME/claudecode-github-automation.git
cd claudecode-github-automation
```

### 2. Create Your `.env` File

```bash
cp .env.example .env
```

Edit `.env` with your credentials:

```bash
GITHUB_TOKEN=ghp_your_actual_token_here
GITHUB_USERNAME=your_github_username
GITHUB_DEFAULT_OWNER=your_github_username
```

### 3. Get Your GitHub Token

1. Go to https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Select scopes: `repo`, `workflow`, `admin:repo_hook`
4. Generate and copy the token
5. Paste into `.env` file

### 4. Initialize Session

```bash
source .env
./scripts/init-session.sh
```

---

## 📖 How It Works

### For Claude Code Users

When you open this project in Claude Code (Web or iOS):

1. **Claude Code automatically reads** `.claude/instructions.md`
2. **It learns** to always use GitHub API with your token
3. **It follows** the complete workflow without reminders
4. **It uses** environment variables from `.env` automatically

### The Magic

The `.claude/instructions.md` file contains explicit, detailed instructions that Claude Code loads at the start of every session. This includes:

- How to load environment variables
- Complete GitHub API commands
- Full workflow from commit to merge
- What to never do and always do
- Troubleshooting steps

---

## 💡 Usage

### For New Projects

When creating a new repository with Claude Code:

1. Copy `.claude/instructions.md` to your new project
2. Copy `.env` file (with your credentials)
3. Claude Code will automatically follow the GitHub workflow

### As a Template

Use this as a starting template for all your projects:

```bash
# Create new project from this template
cp -r claudecode-github-automation my-new-project
cd my-new-project
# Update project-specific details
```

---

## 📝 Key Files Explained

### `.claude/instructions.md`

The brain of the operation. Contains:
- Step-by-step GitHub API workflows
- Complete command examples
- Do's and don'ts
- Troubleshooting guide

**Claude Code reads this automatically** - you don't need to tell it!

### `.env`

Your credentials storage:
```bash
GITHUB_TOKEN=ghp_xxxxx
GITHUB_USERNAME=your_username
GITHUB_DEFAULT_OWNER=your_username
```

**Never commit this file** - it's in `.gitignore`

### `github-api-commands.md`

Quick reference with ready-to-use commands:
- Create repository
- Push code
- Create PR
- Merge PR
- Delete branch

### `START_HERE.md`

Quick start guide for when you need to jump in fast.

---

## 🔧 Workflows Supported

### 1. Create New Repository
```bash
source .env
# Use GitHub API to create repo
# Initialize local git
# Push initial commit
```

### 2. Feature Branch Workflow
```bash
source .env
# Create feature branch
# Make changes and commit
# Push to GitHub
# Create PR via API
# Merge PR via API
```

### 3. Direct Push to Main
```bash
source .env
# Make changes
# Commit
# Push with token in URL
```

---

## 🛡️ Security

- ✅ `.env` file is in `.gitignore` (never committed)
- ✅ Token is only stored locally
- ✅ Commands use environment variables (not hardcoded)
- ✅ Minimal token permissions required

**Best Practices:**
- Rotate tokens every 90 days
- Use tokens with minimum required scopes
- Never share `.env` file
- Don't log or echo full token value

---

## 🐛 Troubleshooting

### Claude Code Not Following Instructions

1. Verify `.claude/instructions.md` exists in project root
2. Check file permissions: `chmod 644 .claude/instructions.md`
3. Restart Claude Code session

### Authentication Errors

1. Check token: `echo ${GITHUB_TOKEN:0:10}...`
2. If empty, run: `source .env`
3. Verify token at: https://github.com/settings/tokens
4. Ensure scopes include: `repo`, `workflow`

### Push Failures

1. Verify URL format: `https://$GITHUB_TOKEN@github.com/USER/REPO.git`
2. Check remote: `git remote -v`
3. Test token: `curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user`

---

## 📚 Additional Resources

- [GitHub REST API Documentation](https://docs.github.com/en/rest)
- [GitHub Token Scopes](https://docs.github.com/en/apps/oauth-apps/building-oauth-apps/scopes-for-oauth-apps)
- [Claude Code Documentation](https://docs.claude.ai)

---

## 🤝 Contributing

This is a template repository. Feel free to:
- Fork and customize for your needs
- Submit improvements via PR
- Share feedback and issues

---

## 📄 License

MIT License - feel free to use this template for any project.

---

## 🎯 Use Cases

Perfect for:
- Solo developers using Claude Code
- Teams standardizing Claude Code workflows
- Projects requiring automated GitHub operations
- Anyone tired of reminding AI about environment variables

---

## 🚀 Next Steps

1. ✅ Set up your `.env` file
2. ✅ Read `START_HERE.md` for quick start
3. ✅ Try creating a test repository
4. ✅ Use this as template for all projects

---

## 🤖 For Claude Code

**IMPORTANT**: This project uses GitHub API with authentication token.

Before ANY GitHub operation:
1. Run: `source .env`
2. Use `$GITHUB_TOKEN` in all API calls
3. See `.claude/instructions.md` for complete workflow

The instructions are in `.claude/instructions.md` - read that file first!

---

**Made with ❤️ for seamless Claude Code + GitHub integration**
