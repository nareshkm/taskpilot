#!/usr/bin/env bash
# Convenience script for TaskPilot Flutter project.
# Usage:
#   ./run.sh [--clean] [--skip-get] [ios|web|all]
# Options:
#   --clean       Run 'flutter clean' before other commands.
#   --skip-get    Skip 'flutter pub get'. By default, pub get runs.
#   ios           Launch on iOS simulator/device.
#   web           Launch on Chrome.
#   all           Launch on both (sequentially).

set -e

# Defaults
DO_CLEAN=false
DO_GET=true
DEVICES=()

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --clean)
      DO_CLEAN=true; shift ;;
    --skip-get)
      DO_GET=false; shift ;;
    ios)
      DEVICES+=("ios"); shift ;;
    web)
      DEVICES+=("chrome"); shift ;;
    all)
      DEVICES=("ios" "chrome"); shift ;;
    *)
      echo "Unknown argument: $1"
      echo "Usage: $0 [--clean] [--skip-get] [ios|web|all]"
      exit 1 ;;
  esac
done

# If no devices specified, default to all
if [ ${#DEVICES[@]} -eq 0 ]; then
  DEVICES=("ios" "chrome")
fi

if [ "$DO_CLEAN" = true ]; then
  echo "==> Cleaning project..."
  flutter clean
fi

if [ "$DO_GET" = true ]; then
  echo "==> Fetching dependencies..."
  flutter pub get
fi

# Scaffold web support if targeting Chrome and missing
if [[ " ${DEVICES[@]} " =~ "chrome" ]]; then
  if [ ! -d web ]; then
    echo "==> Adding web support via 'flutter create .'"
    flutter create . --platforms=web
  fi
fi

for DEVICE in "${DEVICES[@]}"; do
  echo "==> Running on $DEVICE..."
  flutter run -d "$DEVICE"
done