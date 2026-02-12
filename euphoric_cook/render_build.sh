#!/bin/bash
# -----------------------------------------------
# Render Static Site Deploy Script for Flutter Web
# -----------------------------------------------

set -e  # Stop on errors

# -----------------------------------------------
# 1️⃣ Ensure Flutter is installed locally
# (Do this locally once, not on Render)
# -----------------------------------------------
# flutter --version
# flutter pub get

# -----------------------------------------------
# 2️⃣ Build the web release locally
# -----------------------------------------------
echo "Building Flutter web release..."
flutter build web --release

# -----------------------------------------------
# 3️⃣ Copy build output to Render publish folder
# Render static sites automatically serve the 'public' folder
# -----------------------------------------------
echo "Copying build/web to public folder..."
rm -rf public
mkdir -p public
cp -r build/web/* public/

# -----------------------------------------------
# 4️⃣ Done — push repo to Render
# -----------------------------------------------
echo "Flutter web build ready for Render!"
