#!/bin/bash

set -e

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

# Define all published packages (exclude examples)
ALL_PACKAGES=(
  "mono_bloc"
  "mono_bloc_generator"
  "mono_bloc_flutter"
  "mono_bloc_hooks"
)

# Function to show usage
show_usage() {
  echo "Usage: $0 [package_name]"
  echo ""
  echo "Run pana scoring analysis on mono_bloc packages."
  echo ""
  echo "Arguments:"
  echo "  package_name    Optional. Name of specific package to analyze."
  echo "                  If not provided, runs on all packages."
  echo ""
  echo "Available packages:"
  for pkg in "${ALL_PACKAGES[@]}"; do
    echo "  - $pkg"
  done
  echo ""
  echo "Examples:"
  echo "  $0                      # Run on all packages"
  echo "  $0 mono_bloc            # Run on mono_bloc only"
  echo "  $0 mono_bloc_generator  # Run on mono_bloc_generator only"
}

# Check if pana is installed
if ! dart pub global list | grep -q "pana"; then
  echo -e "${YELLOW}pana is not installed. Installing...${NC}"
  dart pub global activate pana
  echo ""
fi

# Function to run pana on a package
run_pana() {
  local package_dir="$1"
  local package_name=$(basename "$package_dir")
  
  echo ""
  echo "================================================"
  echo -e "${CYAN}Analyzing package: $package_name${NC}"
  echo -e "${CYAN}Source: $package_dir${NC}"
  echo "================================================"
  echo ""
  
  cd "$package_dir"
  
  # Run pana on the package directory
  if dart pub global run pana --no-warning --source path .; then
    echo ""
    echo -e "${GREEN}✓ Pana analysis complete for $package_name!${NC}"
  else
    echo ""
    echo -e "${RED}✗ Pana analysis failed for $package_name!${NC}"
    return 1
  fi
}

# Function to validate package name
is_valid_package() {
  local pkg="$1"
  for valid_pkg in "${ALL_PACKAGES[@]}"; do
    if [ "$pkg" == "$valid_pkg" ]; then
      return 0
    fi
  done
  return 1
}

# Determine which packages to run
if [ $# -eq 0 ]; then
  # No argument - run on all packages
  PACKAGES=("${ALL_PACKAGES[@]}")
  echo "================================================"
  echo "Running pana scoring analysis on all packages"
  echo "================================================"
elif [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
  show_usage
  exit 0
else
  # Specific package provided
  if is_valid_package "$1"; then
    PACKAGES=("$1")
    echo "================================================"
    echo "Running pana scoring analysis on: $1"
    echo "================================================"
  else
    echo -e "${RED}Error: Unknown package '$1'${NC}"
    echo ""
    show_usage
    exit 1
  fi
fi

# Get the count of packages
PACKAGE_COUNT=${#PACKAGES[@]}
CURRENT_INDEX=0

# Run pana on each package
for package in "${PACKAGES[@]}"; do
  CURRENT_INDEX=$((CURRENT_INDEX + 1))
  package_path="$ROOT_DIR/$package"
  
  if [ ! -d "$package_path" ]; then
    echo -e "${RED}Package directory not found: $package_path${NC}"
    continue
  fi
  
  run_pana "$package_path"
  
  # Prompt to continue (except for the last package, and only if multiple packages)
  if [ $PACKAGE_COUNT -gt 1 ] && [ $CURRENT_INDEX -lt $PACKAGE_COUNT ]; then
    echo ""
    echo -e "${YELLOW}Press Enter to continue to next package...${NC}"
    read -r
  fi
done

echo ""
echo "================================================"
echo -e "${GREEN}✓ All pana analyses complete!${NC}"
echo "================================================"
