#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION_NUMBER="$(sed -n 's/^VERSION=//p' "$ROOT_DIR/VERSION")"
UPSTREAM_PACKAGE_VERSION="3.6.16"
UPSTREAM_LISTS="$ROOT_DIR/upstream-packages/phplist-${UPSTREAM_PACKAGE_VERSION}/public_html/lists"
COMMON_ROOT="$ROOT_DIR/deploy/common"
MANIFEST="$ROOT_DIR/deploy/common.sha256"

if [[ "$VERSION_NUMBER" != "3.6.17" ]]; then
    echo "Refusing to build unexpected phpList version: $VERSION_NUMBER" >&2
    exit 1
fi

if [[ ! -f "$UPSTREAM_LISTS/base/vendor/autoload.php" ]]; then
    echo "Missing complete upstream package: $UPSTREAM_LISTS" >&2
    echo "Use the verified SourceForge production archive for phpList $UPSTREAM_PACKAGE_VERSION." >&2
    exit 1
fi

mkdir -p "$COMMON_ROOT/lists"

rsync -a --delete --delete-excluded \
    --exclude '.DS_Store' \
    --exclude 'Thumbs.db' \
    --exclude 'config/config.php' \
    --exclude 'admin/plugins/' \
    "$UPSTREAM_LISTS/" "$COMMON_ROOT/lists/"

# Overlay the 3.6.17 source and all common NFS hooks on the last complete
# production distribution. phpList published 3.6.17 as a source-only tag.
rsync -a \
    --exclude '.DS_Store' \
    --exclude 'Thumbs.db' \
    --exclude 'config/config.php' \
    --exclude 'admin/plugins/' \
    "$ROOT_DIR/public_html/lists/" "$COMMON_ROOT/lists/"

cp "$ROOT_DIR/VERSION" "$COMMON_ROOT/VERSION"

(
    cd "$COMMON_ROOT"
    find . -type f -print0 | xargs -0 shasum -a 256 | LC_ALL=C sort
) >"$MANIFEST"

printf 'Built %s from production %s + source %s (%s files)\n' \
    "$COMMON_ROOT" \
    "$UPSTREAM_PACKAGE_VERSION" \
    "$VERSION_NUMBER" \
    "$(wc -l <"$MANIFEST" | tr -d ' ')"
