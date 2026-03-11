#!/bin/bash

# ============================================
# GitHub Upload Script for A225f-T-s9 Kernel
# ============================================
# Author: Mastermind (@mafiadan6)
# Telegram: https://t.me/bitcockiii
# ============================================

echo "=============================================="
echo "  GitHub Upload Script"
echo "  KernelSU-Next + susfs for Samsung A22"
echo "=============================================="
echo ""

# Git configuration
GIT_USER="mafiadan6"
GIT_EMAIL="mafiadan6@users.noreply.github.com"
GIT_REPO="https://github.com/mafiadan6/A225f-T-s9.git"
GIT_BRANCH="main"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -f "build_kernel.sh" ]; then
    echo -e "${RED}Error: Please run this script from the kernel root directory!${NC}"
    exit 1
fi

echo -e "${YELLOW}[*] Configuring git...${NC}"
git config user.name "$GIT_USER"
git config user.email "$GIT_EMAIL"

echo -e "${YELLOW}[*] Setting up remote repository...${NC}"
git remote remove origin 2>/dev/null
git remote add origin "$GIT_REPO"

echo -e "${YELLOW}[*] Cleaning up unnecessary files...${NC}"
# Remove KernelSU-Next submodule (it's a separate repo)
git rm --cached -r KernelSU-Next 2>/dev/null || true
# Remove out folder if exists
git rm -r --cached out 2>/dev/null || true

echo -e "${YELLOW}[*] Staging all files...${NC}"
git add -A

echo -e "${YELLOW}[*] Current changes to commit:${NC}"
git status --short

echo ""
echo -e "${YELLOW}[*] Committing changes...${NC}"
git commit -m "Initial release: KernelSU-Next with susfs v2.0.0

Features:
- KernelSU-Next v3.1.0-legacy-susfs integration
- susfs v2.0.0 full integration (all features enabled)
- kallsyms hiding support
- Module hiding from lsmod
- uname spoofing support
- Custom kernel version: 爪卂丂ㄒ乇尺爪工刀ᗪ丂

Device: Samsung Galaxy A22 (MT6768)
Base: A225MUBSCCYE1

Credits:
- Original backport: @physwizz
- KSU+susfs integration: @Mastermind (mafiadan6)"

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Nothing to commit or commit failed!${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ Commit successful!${NC}"
echo ""
echo -e "${YELLOW}[*] Pushing to GitHub...${NC}"
echo -e "${YELLOW}    Repository: $GIT_REPO${NC}"
echo -e "${YELLOW}    Branch: $GIT_BRANCH${NC}"
echo ""

git push -u origin "$GIT_BRANCH" --force

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}=============================================="
    echo "  ✓ Upload Successful!"
    echo "=============================================="
    echo ""
    echo -e "  Your kernel source is now available at:"
    echo -e "  ${GREEN}https://github.com/mafiadan6/A225f-T-s9${NC}"
    echo ""
    echo -e "  Credits:"
    echo -e "  - Original backport: @physwizz"
    echo -e "  - KSU+susfs integration: @Mastermind"
    echo ""
    echo -e "=============================================="
else
    echo ""
    echo -e "${RED}=============================================="
    echo "  ✗ Upload Failed!"
    echo "=============================================="
    echo ""
    echo -e "  Please check:"
    echo -e "  1. Your GitHub token is valid"
    echo -e "  2. The repository exists"
    echo -e "  3. You have push permissions"
    echo ""
    echo -e "=============================================="
    exit 1
fi
