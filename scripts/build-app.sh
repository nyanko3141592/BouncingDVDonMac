#!/usr/bin/env bash
# .app バンドル組み立て + ad-hoc 署名
# Usage: scripts/build-app.sh [version]
set -euo pipefail

cd "$(dirname "$0")/.."

VERSION="${1:-0.1.0}"
APP_NAME="BouncingDVD"
EXECUTABLE_NAME="DVDBouncer"
BUILD_CONFIG="release"
BUILD_DIR=".build/${BUILD_CONFIG}"
APP_BUNDLE=".build/dist/${APP_NAME}.app"
INFO_PLIST_TEMPLATE="Resources/Info.plist"

echo "==> Building ${EXECUTABLE_NAME} (${BUILD_CONFIG}, arm64) v${VERSION}"
swift build -c "${BUILD_CONFIG}" --arch arm64

echo "==> Assembling ${APP_BUNDLE}"
rm -rf "${APP_BUNDLE}"
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

cp "${BUILD_DIR}/${EXECUTABLE_NAME}" "${APP_BUNDLE}/Contents/MacOS/${EXECUTABLE_NAME}"

sed "s/__VERSION__/${VERSION}/g" "${INFO_PLIST_TEMPLATE}" > "${APP_BUNDLE}/Contents/Info.plist"

printf 'APPL????' > "${APP_BUNDLE}/Contents/PkgInfo"

echo "==> Ad-hoc signing"
codesign --force --deep --sign - "${APP_BUNDLE}"
codesign --verify --verbose=2 "${APP_BUNDLE}" || true

echo ""
echo "Built: ${APP_BUNDLE}"
echo "Try: open ${APP_BUNDLE}"
