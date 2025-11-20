#!/bin/bash
# Initialize Claude Code session with GitHub environment

set -e

echo "🚀 Initializing Claude Code GitHub Session..."
echo ""

# Verify required environment variables
if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ Error: GITHUB_TOKEN environment variable is required"
    echo "Please set it in your Claude Code environment variables settings"
    exit 1
fi

if [ -z "$GITHUB_USERNAME" ]; then
    echo "❌ Error: GITHUB_USERNAME environment variable is required"
    echo "Please set it in your Claude Code environment variables settings"
    exit 1
fi

# Display loaded configuration (masked)
echo "✅ Environment loaded successfully!"
echo ""
echo "Configuration:"
echo "  • GitHub Token: ${GITHUB_TOKEN:0:10}...${GITHUB_TOKEN: -4}"
echo "  • Username: $GITHUB_USERNAME"
echo "  • Default Owner: $GITHUB_DEFAULT_OWNER"
echo ""

# Test GitHub API access
echo "🔍 Testing GitHub API access..."
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: token $GITHUB_TOKEN" \
    https://api.github.com/user)

if [ "$RESPONSE" = "200" ]; then
    echo "✅ GitHub API: Connected"
    
    # Get user info
    USER_INFO=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user)
    ACTUAL_USERNAME=$(echo $USER_INFO | grep -o '"login":"[^"]*' | cut -d'"' -f4)
    echo "  • Authenticated as: $ACTUAL_USERNAME"
else
    echo "❌ GitHub API: Connection failed (HTTP $RESPONSE)"
    echo ""
    echo "Please check:"
    echo "  • Token is valid"
    echo "  • Token has required scopes (repo, workflow)"
    echo "  • Token is not expired"
    exit 1
fi

echo ""
echo "✅ Session initialized!"
echo ""
echo "You're ready to use Claude Code with GitHub automation."
echo "The .claude/instructions.md file will guide Claude Code automatically."
echo ""
