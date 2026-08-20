#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION_NUMBER="$(sed -n 's/^VERSION=//p' "$ROOT_DIR/VERSION")"
COMMON_ROOT="$ROOT_DIR/deploy/common"
MANIFEST="$ROOT_DIR/deploy/common.sha256"

if [[ "$VERSION_NUMBER" != "3.6.17" ]]; then
    echo "Refusing to build unexpected phpList version: $VERSION_NUMBER" >&2
    exit 1
fi

mkdir -p "$COMMON_ROOT/lists"

rsync -a --delete \
    --exclude '.DS_Store' \
    --exclude 'Thumbs.db' \
    --exclude 'config/config.php' \
    --exclude 'admin/plugins/NFSCustomizationsPlugin.php' \
    --exclude 'admin/plugins/NFSCustomizationsPlugin/' \
    "$ROOT_DIR/public_html/lists/" "$COMMON_ROOT/lists/"

cp "$ROOT_DIR/VERSION" "$COMMON_ROOT/VERSION"

(
    cd "$COMMON_ROOT"
    find . -type f -exec shasum -a 256 {} \; | LC_ALL=C sort
) >"$MANIFEST"

printf 'Built %s (%s files)\n' \
    "$COMMON_ROOT" \
    "$(wc -l <"$MANIFEST" | tr -d ' ')"
