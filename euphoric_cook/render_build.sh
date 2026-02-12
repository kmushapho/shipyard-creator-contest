#!/bin/bash

# Clone Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable --depth 1

# Add Flutter to PATH
export PATH="$PWD/flutter/bin:$PATH"

# Get dependencies
flutter pub get

# Build web release
flutter build web --release
