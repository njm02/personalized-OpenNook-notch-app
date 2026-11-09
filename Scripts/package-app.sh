#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
APP_NAME="OpenNookStarter"
APP_BUNDLE="$ROOT_DIR/dist/$APP_NAME.app"
CONTENTS="$APP_BUNDLE/Contents"

cd "$ROOT_DIR"
BUILD_CONFIGURATION="${1:-release}"
case "$BUILD_CONFIGURATION" in
    debug|release) ;;
    *) echo "Usage: $0 [debug|release]" >&2; exit 2 ;;
esac
swift build -c "$BUILD_CONFIGURATION" --product "$APP_NAME"
BIN_PATH=$(swift build -c "$BUILD_CONFIGURATION" --show-bin-path)

mkdir -p "$CONTENTS/MacOS"
cp "$BIN_PATH/$APP_NAME" "$CONTENTS/MacOS/$APP_NAME"

cp "$ROOT_DIR/App/Info.plist" "$CONTENTS/Info.plist"

mkdir -p "$CONTENTS/Resources/OpenNookLicenses"
cp "$ROOT_DIR/Vendor/opennook/LICENSE" "$ROOT_DIR/Vendor/opennook/LICENSE-MIT-NOOKSURFACE" "$ROOT_DIR/Vendor/opennook/NOTICE.md" "$ROOT_DIR/Vendor/opennook/LOCAL_CHANGES.md" "$CONTENTS/Resources/OpenNookLicenses/"
cp -R "$ROOT_DIR/Vendor/opennook/ThirdPartyLicenses" "$CONTENTS/Resources/OpenNookLicenses/"
codesign --force --deep --sign - "$APP_BUNDLE"

echo "Created $APP_BUNDLE"
