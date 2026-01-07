# ============================================
# RELEASE CHECKLIST - ComposeApp iOS
# ============================================

VERSION="1.0.X"  # Change this each time

# --- IN DEVELOPMENT REPO (xcframework) ---
./gradlew clean
./gradlew :composeApp:assembleComposeAppReleaseXCFramework
cd composeApp/build/XCFrameworks/release
zip -r ComposeApp.xcframework.zip ComposeApp.xcframework
xcrun swift package compute-checksum ComposeApp.xcframework.zip
# ☝️ COPY THE CHECKSUM

# --- ON GITHUB (ComposeApp-iOS repo) ---
# 1. Go to: github.com/USERNAME/ComposeApp-iOS/releases/new
# 2. Tag: v1.0.X
# 3. Upload: ComposeApp.xcframework.zip
# 4. Publish

# --- IN DISTRIBUTION REPO (ComposeApp-iOS) ---
#cd ~/ComposeApp-iOS
# Edit Package.swift:
#   - Change URL to: .../v1.0.X/ComposeApp.xcframework.zip
#   - Change checksum to: "PASTE_CHECKSUM_HERE"

#git add Package.swift
#git commit -m "Release v1.0.X"
#git push
#git tag v1.0.X
#git push origin v1.0.X

# DONE! 🎉
