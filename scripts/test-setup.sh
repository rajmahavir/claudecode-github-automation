#!/bin/bash
# Test GitHub API configuration

echo "🧪 Testing GitHub API Configuration..."
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo "❌ .env file not found"
    echo "Create it from .env.example first"
    exit 1
fi

# Load environment
source .env

echo "Testing components:"
echo ""

# Test 1: Token format
echo "1️⃣ Checking token format..."
if [[ $GITHUB_TOKEN == ghp_* ]]; then
    echo "   ✅ Token format looks correct"
else
    echo "   ⚠️  Token doesn't start with 'ghp_' - might be wrong format"
fi

# Test 2: Token length
TOKEN_LENGTH=${#GITHUB_TOKEN}
if [ $TOKEN_LENGTH -eq 40 ]; then
    echo "   ✅ Token length correct (40 characters)"
else
    echo "   ⚠️  Token length is $TOKEN_LENGTH (expected 40)"
fi

echo ""

# Test 3: API Authentication
echo "2️⃣ Testing GitHub API authentication..."
RESPONSE=$(curl -s -w "\n%{http_code}" \
    -H "Authorization: token $GITHUB_TOKEN" \
    https://api.github.com/user)

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

if [ "$HTTP_CODE" = "200" ]; then
    echo "   ✅ Authentication successful"
    
    # Extract user info
    LOGIN=$(echo $BODY | grep -o '"login":"[^"]*' | cut -d'"' -f4)
    NAME=$(echo $BODY | grep -o '"name":"[^"]*' | cut -d'"' -f4)
    
    echo "   • Logged in as: $LOGIN"
    echo "   • Name: $NAME"
    
    if [ "$LOGIN" != "$GITHUB_USERNAME" ]; then
        echo "   ⚠️  Warning: Logged in as '$LOGIN' but GITHUB_USERNAME is set to '$GITHUB_USERNAME'"
    fi
else
    echo "   ❌ Authentication failed (HTTP $HTTP_CODE)"
    echo "   Response: $BODY"
fi

echo ""

# Test 4: Token scopes
echo "3️⃣ Checking token scopes..."
SCOPES=$(curl -s -I \
    -H "Authorization: token $GITHUB_TOKEN" \
    https://api.github.com/user | grep -i "x-oauth-scopes" | cut -d':' -f2 | tr -d '\r')

if [ -z "$SCOPES" ]; then
    echo "   ⚠️  Could not retrieve scopes"
else
    echo "   Available scopes:$SCOPES"
    
    # Check for required scopes
    if echo "$SCOPES" | grep -q "repo"; then
        echo "   ✅ Has 'repo' scope"
    else
        echo "   ❌ Missing 'repo' scope"
    fi
    
    if echo "$SCOPES" | grep -q "workflow"; then
        echo "   ✅ Has 'workflow' scope"
    else
        echo "   ⚠️  Missing 'workflow' scope (recommended)"
    fi
fi

echo ""

# Test 5: Repository access
echo "4️⃣ Testing repository access..."
REPO_RESPONSE=$(curl -s -w "\n%{http_code}" \
    -H "Authorization: token $GITHUB_TOKEN" \
    https://api.github.com/user/repos?per_page=1)

REPO_HTTP_CODE=$(echo "$REPO_RESPONSE" | tail -n1)

if [ "$REPO_HTTP_CODE" = "200" ]; then
    echo "   ✅ Can access repositories"
    
    REPO_COUNT=$(curl -s \
        -H "Authorization: token $GITHUB_TOKEN" \
        https://api.github.com/user | grep -o '"public_repos":[0-9]*' | cut -d':' -f2)
    
    echo "   • Public repositories: $REPO_COUNT"
else
    echo "   ❌ Cannot access repositories (HTTP $REPO_HTTP_CODE)"
fi

echo ""

# Test 6: Git configuration
echo "5️⃣ Checking git configuration..."
if command -v git &> /dev/null; then
    echo "   ✅ Git is installed"
    
    GIT_USER=$(git config --get user.name 2>/dev/null || echo "Not set")
    GIT_EMAIL=$(git config --get user.email 2>/dev/null || echo "Not set")
    
    echo "   • Git user: $GIT_USER"
    echo "   • Git email: $GIT_EMAIL"
    
    if [ "$GIT_USER" = "Not set" ] || [ "$GIT_EMAIL" = "Not set" ]; then
        echo "   ℹ️  Configure git with:"
        echo "      git config --global user.name \"Your Name\""
        echo "      git config --global user.email \"your.email@example.com\""
    fi
else
    echo "   ❌ Git is not installed"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Final summary
if [ "$HTTP_CODE" = "200" ] && [ "$REPO_HTTP_CODE" = "200" ]; then
    echo "✅ All tests passed! You're ready to use GitHub API."
    echo ""
    echo "Next steps:"
    echo "  • Start using Claude Code with this project"
    echo "  • Claude will automatically read .claude/instructions.md"
    echo "  • All GitHub operations will use your token"
    exit 0
else
    echo "❌ Some tests failed. Please fix the issues above."
    echo ""
    echo "Common fixes:"
    echo "  • Regenerate token at: https://github.com/settings/tokens"
    echo "  • Ensure scopes include: repo, workflow"
    echo "  • Update .env with new token"
    exit 1
fi
