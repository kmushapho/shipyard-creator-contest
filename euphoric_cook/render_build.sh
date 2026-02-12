#!/bin/bash
set -e  # stop on errors

# Set cache directories
FLUTTER_DIR="/cache/flutter"
PUB_CACHE_DIR="/cache/pub-cache"

# Clone Flutter if not cached
if [ ! -d "$FLUTTER_DIR" ]; then
    echo "Cloning Flutter SDK..."
    git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$FLUTTER_DIR"
else
    echo "Using cached Flutter SDK"
fi

# Add Flutter to PATH
export PATH="$FLUTTER_DIR/bin:$PATH"

# Use cached pub packages if available
export PUB_CACHE="$PUB_CACHE_DIR"

# Get dependencies
flutter pub get

# Build web release
flutter build web --release
