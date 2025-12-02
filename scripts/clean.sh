#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

echo "Cleaning mono_bloc..."
(cd mono_bloc && rm -rf .dart_tool)

echo "Cleaning example..."
(cd example && flutter clean && rm -rf .dart_tool)

echo "Cleaning mono_bloc_generator..."
(cd mono_bloc_generator && rm -rf .dart_tool)

echo "Cleaning mono_bloc_flutter..."
(cd mono_bloc_flutter && flutter clean && rm -rf .dart_tool)

echo "Cleaning mono_bloc_hooks..."
(cd mono_bloc_hooks && flutter clean && rm -rf .dart_tool)

echo "Clean complete."

echo "Install dependencies for mono_bloc..."
(cd mono_bloc && dart pub get)

echo "Install dependencies for example..."
(cd example && flutter pub get)

echo "Install dependencies for mono_bloc_generator..."
(cd mono_bloc_generator && dart pub get)

echo "Install dependencies for mono_bloc_flutter..."
(cd mono_bloc_flutter && flutter pub get)

echo "Install dependencies for mono_bloc_hooks..."
(cd mono_bloc_hooks && flutter pub get)

echo "Dependency installation complete."