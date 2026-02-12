#!/bin/bash
# -----------------------------------------------
# Render Static Site Deploy Script for Flutter Web
# -----------------------------------------------

set -e  # Stop on errors

# -----------------------------------------------
# 1️⃣ Build Flutter Web Locally
# -----------------------------------------------
# IMPORTANT: Do this locally BEFORE running the script on Render
# flutter pub get
# flutter build web --release
echo "✅ Ensure you have run 'flutter build web --release' locally before pushing."

# -----------------------------------------------
# 2️⃣ Copy build output to Render 'public' folder
# Render static sites automatically serve the 'public' folder
# -----------------------------------------------
echo "📂 Copying build/web to public folder..."
rm -rf public
mkdir -p public
cp -r build/web/* public/

# -----------------------------------------------
# 3️⃣ Done — Ready to deploy
# -----------------------------------------------
echo "🎉 Flutter web build ready for Render! Push your repo and Render will serve the 'public' folder."
