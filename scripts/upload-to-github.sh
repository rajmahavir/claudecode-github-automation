#!/bin/bash

#############################################################################
# GitHub API File Upload Script
#
# Purpose: Upload files to GitHub repository via API
#          (Workaround for git commit signing failures in Web/iOS)
#
# Usage: ./upload-to-github.sh <repo-name> [commit-message] [branch]
#
# Examples:
#   ./upload-to-github.sh my-repo
#   ./upload-to-github.sh my-repo "Update files"
#   ./upload-to-github.sh my-repo "Feature update" "feature/new"
#
# Prerequisites:
#   - GITHUB_TOKEN and GITHUB_USERNAME environment variables
#   - base64, curl, find commands available
#############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }

# Verify required environment variables
verify_environment() {
  # Verify required variables
  if [ -z "$GITHUB_TOKEN" ]; then
    print_error "GITHUB_TOKEN environment variable is required"
    print_info "Please set it in your Claude Code environment variables settings"
    exit 1
  fi

  if [ -z "$GITHUB_USERNAME" ]; then
    print_error "GITHUB_USERNAME environment variable is required"
    print_info "Please set it in your Claude Code environment variables settings"
    exit 1
  fi

  print_success "Environment variables verified"
  print_info "Username: $GITHUB_USERNAME"
  print_info "Token: ${GITHUB_TOKEN:0:10}..."
}

# Function to upload a single file
upload_file() {
  local file_path="$1"
  local repo="$2"
  local branch="$3"
  local message="$4"

  # Get base64 content (no line wrapping)
  local content
  content=$(base64 -w 0 "$file_path" 2>/dev/null)
  if [ $? -ne 0 ]; then
    print_error "Failed to encode $file_path"
    return 1
  fi

  # Try to get existing file SHA
  local sha
  sha=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$GITHUB_USERNAME/$repo/contents/$file_path?ref=$branch" 2>/dev/null | \
    grep '"sha"' | head -1 | cut -d'"' -f4)

  # Build JSON payload
  local json
  if [ -n "$sha" ]; then
    # Update existing file
    json="{\"message\":\"$message\",\"content\":\"$content\",\"sha\":\"$sha\",\"branch\":\"$branch\"}"
  else
    # Create new file
    json="{\"message\":\"$message\",\"content\":\"$content\",\"branch\":\"$branch\"}"
  fi

  # Upload file
  local response
  response=$(curl -s -X PUT \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/$GITHUB_USERNAME/$repo/contents/$file_path" \
    -d "$json")

  # Check for errors
  if echo "$response" | grep -q '"message".*"error"' || echo "$response" | grep -q '"message".*"Invalid"'; then
    print_error "Failed to upload $file_path"
    echo "$response" | grep '"message"' | head -1
    return 1
  fi

  return 0
}

# Main upload function
bulk_upload() {
  local repo="$1"
  local message="$2"
  local branch="${3:-main}"

  print_info "Starting bulk upload to $GITHUB_USERNAME/$repo (branch: $branch)"
  echo ""

  # Verify repository exists
  local repo_check
  repo_check=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    "https://api.github.com/repos/$GITHUB_USERNAME/$repo")

  if echo "$repo_check" | grep -q '"message".*"Not Found"'; then
    print_error "Repository $GITHUB_USERNAME/$repo not found"
    print_info "Create it first with: curl -X POST -H \"Authorization: token \$GITHUB_TOKEN\" https://api.github.com/user/repos -d '{\"name\":\"$repo\"}'"
    exit 1
  fi

  # Find and upload files
  local uploaded=0
  local failed=0
  local skipped=0

  # Files and directories to exclude
  local exclude_patterns=(
    -path '*/.git/*'
    -o -path '*/node_modules/*'
    -o -path '*/.env'
    -o -path '*/.DS_Store'
    -o -path '*/.*/.git/*'
  )

  print_info "Finding files to upload..."
  echo ""

  while IFS= read -r -d '' file; do
    # Remove leading ./
    local clean_path="${file#./}"

    echo -n "📤 Uploading: $clean_path ... "

    if upload_file "$clean_path" "$repo" "$branch" "$message"; then
      print_success "Done"
      ((uploaded++))
    else
      print_error "Failed"
      ((failed++))
    fi

    # Rate limiting - wait between uploads
    sleep 0.5

  done < <(find . -type f \
    \( "${exclude_patterns[@]}" \) -prune -o \
    -type f -print0)

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  print_success "Upload Summary"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "✅ Uploaded:    $uploaded files"
  echo "❌ Failed:      $failed files"
  echo "⏭️  Skipped:     $skipped files"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  if [ $failed -gt 0 ]; then
    print_warning "Some files failed to upload. Check errors above."
    exit 1
  fi

  print_success "All files uploaded successfully!"
  print_info "View at: https://github.com/$GITHUB_USERNAME/$repo/tree/$branch"
}

# Usage information
show_usage() {
  cat << EOF
${BLUE}GitHub API File Upload Script${NC}

${YELLOW}Usage:${NC}
  ./upload-to-github.sh <repo-name> [commit-message] [branch]

${YELLOW}Arguments:${NC}
  repo-name        Repository name (required)
  commit-message   Commit message (default: "Upload files via API")
  branch           Target branch (default: "main")

${YELLOW}Examples:${NC}
  ./upload-to-github.sh my-repo
  ./upload-to-github.sh my-repo "Update documentation"
  ./upload-to-github.sh my-repo "Add feature" "feature/new"

${YELLOW}Prerequisites:${NC}
  - GITHUB_TOKEN and GITHUB_USERNAME environment variables set
  - Repository must already exist on GitHub

${YELLOW}Notes:${NC}
  - This script uploads ALL files in the current directory
  - Excludes: .git/, node_modules/, .env, .DS_Store
  - Handles both new and existing files automatically
  - Includes rate limiting (0.5s between uploads)

${YELLOW}Why use this instead of git push?${NC}
  Git commit signing fails in Claude Code Web/iOS with:
  "signing failed: signing operation failed"

  This script uses GitHub API to upload files directly,
  bypassing git commit entirely.

EOF
}

# Main script
main() {
  # Show help if requested
  if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_usage
    exit 0
  fi

  # Check arguments
  if [ $# -lt 1 ]; then
    print_error "Repository name is required"
    echo ""
    show_usage
    exit 1
  fi

  local repo="$1"
  local message="${2:-Upload files via API}"
  local branch="${3:-main}"

  # Verify environment
  verify_environment

  # Confirm action
  echo ""
  print_warning "About to upload files to: $GITHUB_USERNAME/$repo (branch: $branch)"
  print_info "Commit message: $message"
  echo ""
  read -p "Continue? (y/N) " -n 1 -r
  echo ""

  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Upload cancelled"
    exit 0
  fi

  echo ""

  # Perform upload
  bulk_upload "$repo" "$message" "$branch"
}

# Run main function
main "$@"
