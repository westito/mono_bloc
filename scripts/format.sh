#!/bin/bash

# Don't exit on error - we want to continue formatting all packages
set +e

echo "================================================"
echo "Running dart format on all packages"
echo "================================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the script directory (where this script is located)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Get the root directory (parent of scripts)
ROOT_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"

# Define all packages (including examples)
PACKAGES=(
  "mono_bloc"
  "mono_bloc_generator"
  "mono_bloc_flutter"
  "mono_bloc_hooks"
  "example"
  "mono_bloc/example"
)

# Function to run dart format on a package
run_format() {
  local package_dir="$1"
  local package_name=$(basename "$package_dir")
  
  echo -e "${CYAN}Formatting package: $package_name${NC}"
  echo -e "${CYAN}Path: $package_dir${NC}"
  
  cd "$package_dir"
  
  # Use hardcoded line length of 80 (from mono_bloc/analysis_options.yaml)
  local page_width=80
  echo -e "${CYAN}Using line length: $page_width${NC}"
  
  # Temporarily rename analysis_options.yaml if it has broken includes
  local renamed_analysis=0
  if [ -f "analysis_options.yaml" ] && grep -q "include:.*\.\./" "analysis_options.yaml" 2>/dev/null; then
    mv analysis_options.yaml analysis_options.yaml.bak 2>/dev/null && renamed_analysis=1
  fi
  
  # Format specific directories that should exist
  local formatted=0

  for dir in lib test bin; do
    if [ -d "$dir" ]; then
      if dart format --line-length "$page_width" "$dir" > /dev/null 2>&1; then
        formatted=1
      fi
    fi
  done
  
  # Restore analysis_options.yaml if we renamed it
  if [ $renamed_analysis -eq 1 ]; then
    mv analysis_options.yaml.bak analysis_options.yaml 2>/dev/null
  fi
  
  if [ $formatted -eq 1 ]; then
    echo -e "${GREEN}✓ Format complete for $package_name${NC}"
    echo ""
  else
    echo -e "${YELLOW}⚠ No directories to format in $package_name${NC}"
    echo ""
  fi
}

# Run dart format on each package
for package in "${PACKAGES[@]}"; do
  package_path="$ROOT_DIR/$package"
  
  if [ ! -d "$package_path" ]; then
    echo -e "${RED}Package directory not found: $package_path${NC}"
    continue
  fi
  
  run_format "$package_path"
done

echo ""
echo "================================================"
echo -e "${GREEN}✓ All packages formatted!${NC}"
echo "================================================"
