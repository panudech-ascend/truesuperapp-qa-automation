#!/usr/bin/env bash
# Builds the app under test and drops the APK into apps/.
#
# The APK is ~177 MB and is gitignored, so every clone starts without one.
# Run this once before the first test run, and again whenever the app changes.
set -euo pipefail

APP_REPO="${APP_REPO:-../truesuperapp}"
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ ! -d "$APP_REPO" ]; then
  echo "App repo not found at: $APP_REPO" >&2
  echo "Set APP_REPO to where truesuperapp is checked out." >&2
  exit 1
fi

# Debug, not release: MainActivity only enables WebView debugging for a
# debuggable build, and without it Appium cannot see inside a miniapp.
echo "Building debug APK from $APP_REPO ..."
(cd "$APP_REPO" && flutter build apk --debug)

mkdir -p "$HERE/apps"
cp "$APP_REPO/build/app/outputs/flutter-apk/app-debug.apk" "$HERE/apps/"
echo "Copied to $HERE/apps/app-debug.apk"

if command -v adb >/dev/null 2>&1 && [ -n "$(adb devices | sed -n '2p')" ]; then
  echo "Installing on the attached device ..."
  adb install -r "$HERE/apps/app-debug.apk"
fi
