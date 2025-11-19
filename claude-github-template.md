# Claude Code GitHub Template

Use this template when creating new projects with Claude Code that need GitHub integration.

---

## How to Use This Template

### Option 1: Copy Files to New Project

```bash
# Copy the essential files
cp .claude/instructions.md /path/to/new-project/.claude/
cp .env /path/to/new-project/
cp github-api-commands.md /path/to/new-project/
```

### Option 2: Ask Claude Code

When starting a new project with Claude Code, say:

```
Create a new project with GitHub automation. 
Copy the .claude/instructions.md from the claudecode-github-automation 
template and set up .env file.
```

---

## Files to Include in Every Project

### Required Files

1. **`.claude/instructions.md`** - Core automation instructions
2. **`.env`** - Your GitHub credentials (never commit!)
3. **`.gitignore`** - Includes .env and other sensitive files

### Recommended Files

4. **`github-api-commands.md`** - Quick command reference
5. **`README.md`** - Update with project-specific info
6. **`START_HERE.md`** - Quick start for team members

---

## Template Structure

```
your-new-project/
├── .claude/
│   └── instructions.md          # Claude Code automation guide
├── .env                          # Your credentials (gitignored)
├── .gitignore                   # Protects sensitive files
├── README.md                    # Project documentation
├── START_HERE.md               # Quick start guide
├── github-api-commands.md      # Command reference
└── [your project files]
```

---

## Quick Setup for New Project

### Step 1: Create Project Directory

```bash
mkdir my-new-project
cd my-new-project
```

### Step 2: Copy Template Files

```bash
# Copy from claudecode-github-automation
cp -r /path/to/claudecode-github-automation/.claude .
cp /path/to/claudecode-github-automation/.env .
cp /path/to/claudecode-github-automation/.gitignore .
cp /path/to/claudecode-github-automation/github-api-commands.md .
```

### Step 3: Initialize Git

```bash
git init
git branch -m main
```

### Step 4: Start Coding with Claude Code

Open the project in Claude Code and start working. Claude will:
- Automatically read `.claude/instructions.md`
- Use GitHub API with your token from `.env`
- Follow the complete workflow without reminders

---

## Environment Variables Required

Your `.env` file must contain:

```bash
# GitHub Personal Access Token
GITHUB_TOKEN=ghp_your_token_here

# Your GitHub username
GITHUB_USERNAME=your_username

# Default owner for repositories (usually same as username)
GITHUB_DEFAULT_OWNER=your_username
```

---

## Customizing for Your Project

### Update .claude/instructions.md

You can customize the instructions for project-specific needs:

```markdown
# Project-Specific Instructions

## This Project Uses:
- Python 3.11
- FastAPI framework
- PostgreSQL database

## Additional Workflow Steps:
1. Run tests before pushing: `pytest`
2. Format code: `black .`
3. Check linting: `flake8`

[Keep the GitHub API sections from the original template]
```

### Add Project-Specific Commands

Add to `github-api-commands.md`:

```markdown
## Project-Specific Commands

### Run Tests
\`\`\`bash
pytest tests/
\`\`\`

### Deploy to Production
\`\`\`bash
./scripts/deploy.sh production
\`\`\`
```

---

## For Team Projects

When sharing this setup with team members:

### Each Team Member Needs:

1. Their own `.env` file with their personal GitHub token
2. Same `.claude/instructions.md` (committed to repo)
3. Claude Code installed

### What to Commit:

✅ Commit:
- `.claude/instructions.md`
- `.gitignore`
- `github-api-commands.md`
- `README.md`
- Project code

❌ Never Commit:
- `.env` file
- Tokens or credentials
- Personal configuration

---

## Integration with CI/CD

The GitHub API approach works great with CI/CD:

```yaml
# .github/workflows/ci.yml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run tests
        run: pytest
```

Claude Code can create PRs, and GitHub Actions will run automatically.

---

## Best Practices

### Security

- ✅ Use separate tokens for different projects
- ✅ Rotate tokens every 90 days
- ✅ Use minimum required permissions
- ✅ Never hardcode tokens in code
- ✅ Add `.env` to `.gitignore`

### Workflow

- ✅ Use feature branches for changes
- ✅ Create PRs for review
- ✅ Merge via API after approval
- ✅ Delete branches after merging
- ✅ Keep commit messages clear

### Claude Code

- ✅ Keep `.claude/instructions.md` updated
- ✅ Add project-specific workflows
- ✅ Document special requirements
- ✅ Include troubleshooting steps

---

## Common Patterns

### Pattern 1: Simple Feature

```
You: "Add a login page"
Claude Code: 
  - Reads .claude/instructions.md
  - Loads .env automatically
  - Creates feature branch
  - Implements login page
  - Pushes and creates PR
```

### Pattern 2: Bug Fix

```
You: "Fix the navigation bug in PR #12"
Claude Code:
  - Checks out PR branch
  - Fixes the bug
  - Pushes update
  - Comments on PR
```

### Pattern 3: Release

```
You: "Create release v1.0.0"
Claude Code:
  - Merges all pending PRs
  - Updates version numbers
  - Creates git tag
  - Creates GitHub release
```

---

## Extending the Template

### Add More Tools

You can extend `.claude/instructions.md` with:

- Database migration commands
- Docker deployment steps
- Testing frameworks
- Code formatting rules
- Linting requirements

### Example Extension

```markdown
## Database Migrations

Before pushing changes:
1. Create migration: `alembic revision --autogenerate -m "description"`
2. Review migration file
3. Test migration: `alembic upgrade head`
4. Commit migration file with code changes
```

---

## Troubleshooting

### Claude Code Not Using Token

1. Check `.claude/instructions.md` exists
2. Verify `.env` file has correct token
3. Try explicitly: "Read .claude/instructions.md first"

### Token Expired

1. Generate new token at https://github.com/settings/tokens
2. Update `.env` file
3. Run `source .env`

### Authentication Errors

1. Check token scopes include `repo`, `workflow`
2. Test: `curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user`
3. Regenerate if needed

---

## Version History

- **v1.0** - Initial template with GitHub API automation
- Add your version notes here as you customize

---

## Resources

- [GitHub REST API Docs](https://docs.github.com/en/rest)
- [Claude Code Documentation](https://docs.claude.ai)
- [Git Documentation](https://git-scm.com/doc)

---

## License

This template is provided as-is. Customize freely for your projects.

---

**Template created for seamless Claude Code + GitHub integration** 🚀
