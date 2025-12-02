#!/bin/bash

set -e

echo "================================================"
echo "Running tests for MonoBloc"
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

./scripts/clean.sh
./scripts/generate.sh

# Track test results
FAILED_TESTS=()

# Test mono_bloc_generator
echo -e "${YELLOW}[1/2] Running tests for mono_bloc_generator...${NC}"
cd "$ROOT_DIR/mono_bloc_generator"
if dart test; then
    echo -e "${GREEN}✓ Generator tests passed${NC}"
else
    echo -e "${RED}✗ Generator tests failed${NC}"
    FAILED_TESTS+=("mono_bloc_generator")
fi
echo ""

# Test example app
echo -e "${YELLOW}[2/2] Running tests for example app...${NC}"
cd "$ROOT_DIR/example"
if flutter test; then
    echo -e "${GREEN}✓ Example app tests passed${NC}"
else
    echo -e "${RED}✗ Example app tests failed${NC}"
    FAILED_TESTS+=("example")
fi
echo ""

# Summary
echo "================================================"
if [ ${#FAILED_TESTS[@]} -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    echo "================================================"
    exit 0
else
    echo -e "${RED}✗ Some tests failed:${NC}"
    for test in "${FAILED_TESTS[@]}"; do
        echo -e "${RED}  - $test${NC}"
    done
    echo "================================================"
    exit 1
fi
