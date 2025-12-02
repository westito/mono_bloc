#!/bin/bash

set -e

echo "================================================"
echo "Publishing MonoBloc packages"
echo "================================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get the root directory (parent of scripts/)
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo -e "${CYAN}Root directory: $ROOT_DIR${NC}"
echo ""

# Packages to publish (in dependency order)
PACKAGES=(
    "mono_bloc"
    "mono_bloc_generator"
    "mono_bloc_flutter"
    "mono_bloc_hooks"
)

# Track publish results
FAILED_PACKAGES=()

for i in "${!PACKAGES[@]}"; do
    PACKAGE="${PACKAGES[$i]}"
    NUM=$((i + 1))
    TOTAL=${#PACKAGES[@]}
    
    echo -e "${YELLOW}[$NUM/$TOTAL] Publishing $PACKAGE...${NC}"
    cd "$ROOT_DIR/$PACKAGE"
    
    if dart pub publish; then
        echo -e "${GREEN}Published $PACKAGE${NC}"
    else
        echo -e "${RED}Failed to publish $PACKAGE${NC}"
        FAILED_PACKAGES+=("$PACKAGE")
    fi
    echo ""
done

# Summary
echo "================================================"
if [ ${#FAILED_PACKAGES[@]} -eq 0 ]; then
    echo -e "${GREEN}All packages published successfully!${NC}"
    echo "================================================"
    exit 0
else
    echo -e "${RED}Some packages failed to publish:${NC}"
    for pkg in "${FAILED_PACKAGES[@]}"; do
        echo -e "${RED}  - $pkg${NC}"
    done
    echo "================================================"
    exit 1
fi
