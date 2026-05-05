#!/usr/bin/env bash
# .app から DMG を作成
# Usage: scripts/build-dmg.sh [version]
# build-app.sh を先に実行しておくこと
set -euo pipefail

cd "$(dirname "$0")/.."

VERSION="${1:-0.1.0}"
APP_NAME="BouncingLogo"
APP_BUNDLE=".build/dist/${APP_NAME}.app"
DMG_NAME="BouncingLogo-${VERSION}.dmg"
DMG_PATH=".build/dist/${DMG_NAME}"

if [ ! -d "${APP_BUNDLE}" ]; then
    echo "ERROR: ${APP_BUNDLE} not found. Run scripts/build-app.sh ${VERSION} first." >&2
    exit 1
fi

echo "==> Creating ${DMG_PATH}"
rm -f "${DMG_PATH}"

STAGING="$(mktemp -d)"
trap "rm -rf '${STAGING}'" EXIT

cp -R "${APP_BUNDLE}" "${STAGING}/"
ln -s /Applications "${STAGING}/Applications"

hdiutil create \
    -volname "${APP_NAME}" \
    -srcfolder "${STAGING}" \
    -ov \
    -format UDZO \
    "${DMG_PATH}" >/dev/null

echo ""
echo "DMG: ${DMG_PATH}"
echo "Size: $(du -h "${DMG_PATH}" | cut -f1)"
echo "SHA256:"
shasum -a 256 "${DMG_PATH}" | awk '{print "  "$1}'
