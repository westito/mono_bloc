#!/bin/bash

set -e

echo "================================================"
echo "Running code generation for MonoBloc"
echo "================================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get the root directory (parent of scripts/)
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo -e "${CYAN}Root directory: $ROOT_DIR${NC}"
echo ""

# Generate for mono_bloc_generator package tests
echo -e "${YELLOW}[1/4] Generating code for mono_bloc_generator tests...${NC}"
cd "$ROOT_DIR/mono_bloc_generator"
dart run build_runner build --delete-conflicting-outputs
echo -e "${GREEN}✓ Generator tests generated${NC}"
echo ""

# Generate for mono_bloc/example
echo -e "${YELLOW}[2/4] Generating code for mono_bloc/example...${NC}"
cd "$ROOT_DIR/mono_bloc/example"
dart run build_runner build --delete-conflicting-outputs
echo -e "${GREEN}✓ mono_bloc/example generated${NC}"
echo ""

# Generate for example app
echo -e "${YELLOW}[3/4] Generating code for example app...${NC}"
cd "$ROOT_DIR/example"
dart run build_runner build --delete-conflicting-outputs
echo -e "${GREEN}✓ Example app generated${NC}"
echo ""

# Format all Dart code in the monorepo
echo -e "${YELLOW}[4/4] Formatting all Dart code...${NC}"
cd "$ROOT_DIR"
dart format .
echo -e "${GREEN}✓ Code formatted${NC}"
echo ""

echo "================================================"
echo -e "${GREEN}✓ All code generation complete!${NC}"
echo "================================================"
