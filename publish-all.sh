#!/bin/bash
#!/bin/bash
# publish-all.sh
# Creates releases for both Android (AAR) and iOS (XCFramework)

set -e

VERSION=$1

if [ -z "$VERSION" ]; then
    echo "❌ Error: Version required"
    echo "Usage: ./publish-all.sh 1.1.1"
    exit 1
fi

echo "🚀 Publishing version $VERSION for Android and iOS"
echo ""

# ============================================
# Build Android AAR
# ============================================
echo "📦 Step 1/4: Building Android AAR..."
./gradlew :composeApp:assembleRelease

AAR_PATH="composeApp/build/outputs/aar/composeApp-release.aar"

if [ ! -f "$AAR_PATH" ]; then
    echo "❌ AAR not found at $AAR_PATH"
    exit 1
fi

echo "✅ Android AAR built: $AAR_PATH"
echo ""

# ============================================
# Build iOS XCFramework
# ============================================
echo "📦 Step 2/4: Building iOS XCFramework..."
./gradlew :composeApp:assembleComposeAppReleaseXCFramework

XCFRAMEWORK_PATH="composeApp/build/XCFrameworks/release/ComposeApp.xcframework"

if [ ! -d "$XCFRAMEWORK_PATH" ]; then
    echo "❌ XCFramework not found at $XCFRAMEWORK_PATH"
    exit 1
fi

# Zip the XCFramework
cd composeApp/build/XCFrameworks/release
zip -r ComposeApp.xcframework.zip ComposeApp.xcframework
XCFRAMEWORK_ZIP="ComposeApp.xcframework.zip"
cd -

# Calculate checksum for SPM
CHECKSUM=$(xcrun swift package compute-checksum "composeApp/build/XCFrameworks/release/$XCFRAMEWORK_ZIP")

echo "✅ iOS XCFramework built and zipped"
echo "✅ Checksum: $CHECKSUM"
echo ""

# ============================================
# Create Release Directory
# ============================================
echo "📋 Step 3/4: Preparing release artifacts..."

RELEASE_DIR="releases/v$VERSION"
mkdir -p "$RELEASE_DIR"

# Copy AAR
cp "$AAR_PATH" "$RELEASE_DIR/ComposeApp-android-$VERSION.aar"

# Copy XCFramework
cp "composeApp/build/XCFrameworks/release/$XCFRAMEWORK_ZIP" "$RELEASE_DIR/ComposeApp-ios-$VERSION.xcframework.zip"

# Create README for the release
cat > "$RELEASE_DIR/README.md" << EOF
# ComposeApp v$VERSION

## For Android Developers

Download: \`ComposeApp-android-$VERSION.aar\`

### Installation

1. Download the AAR file
2. Place it in your project's \`libs\` folder
3. Add to your \`build.gradle.kts\`:

\`\`\`kotlin
dependencies {
    implementation(files("libs/ComposeApp-android-$VERSION.aar"))
}
\`\`\`

## For iOS Developers

Download: \`ComposeApp-ios-$VERSION.xcframework.zip\`

### Installation via SPM

Add to your \`Package.swift\`:

\`\`\`swift
.binaryTarget(
    name: "ComposeApp",
    url: "https://github.com/developerroshan09/xcframework/releases/download/v$VERSION/ComposeApp-ios-$VERSION.xcframework.zip",
    checksum: "$CHECKSUM"
)
\`\`\`

### Manual Installation

1. Download and unzip the XCFramework
2. Drag \`ComposeApp.xcframework\` into your Xcode project
3. Make sure "Copy items if needed" is checked

## Requirements

- **Android**: minSdk 24, compileSdk 35
- **iOS**: iOS 14.0+

## Usage

\`\`\`kotlin
// Android
import com.xcframework.test.*

val greeting = Greeting().greet()
\`\`\`

\`\`\`swift
// iOS
import ComposeApp

let greeting = Greeting().greet()
\`\`\`
EOF

echo "✅ Release artifacts prepared in $RELEASE_DIR/"
echo ""

# ============================================
# Instructions
# ============================================
echo "📋 Step 4/4: Next steps"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Your release artifacts are ready in: $RELEASE_DIR/"
echo ""
echo "📦 Files to upload:"
echo "   1. ComposeApp-android-$VERSION.aar"
echo "   2. ComposeApp-ios-$VERSION.xcframework.zip"
echo "   3. README.md"
echo ""
echo "🔐 iOS XCFramework Checksum:"
echo "   $CHECKSUM"
echo ""
echo "📋 Create GitHub Release:"
echo "   1. Go to: https://github.com/developerroshan09/xcframework/releases/new"
echo "   2. Tag: v$VERSION"
echo "   3. Title: Release v$VERSION"
echo "   4. Description: Copy content from $RELEASE_DIR/README.md"
echo "   5. Upload all files from $RELEASE_DIR/"
echo "   6. Publish release"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 Done! Both Android and iOS artifacts are ready!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
