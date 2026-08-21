#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION_NUMBER="$(sed -n 's/^VERSION=//p' "$ROOT_DIR/VERSION")"
UPSTREAM_PACKAGE_VERSION="3.7.0"
UPSTREAM_PACKAGE_SHA256="614475133e5c0983f0021b95386a5f03ffe44f4640dd1079a1b083b7def57437"
UPSTREAM_ARCHIVE="$ROOT_DIR/upstream-packages/phplist-${UPSTREAM_PACKAGE_VERSION}.tgz"
UPSTREAM_LISTS="$ROOT_DIR/upstream-packages/phplist-${UPSTREAM_PACKAGE_VERSION}/public_html/lists"
COMMON_ROOT="$ROOT_DIR/deploy/common"
COMMON_LISTS="$COMMON_ROOT/root/lists"
MANIFEST="$ROOT_DIR/deploy/common.sha256"

if [[ "$VERSION_NUMBER" != "$UPSTREAM_PACKAGE_VERSION" ]]; then
    echo "Refusing to build unexpected phpList version: $VERSION_NUMBER" >&2
    exit 1
fi

actual_package_sha256="$(shasum -a 256 "$UPSTREAM_ARCHIVE" | awk '{print $1}')"
if [[ "$actual_package_sha256" != "$UPSTREAM_PACKAGE_SHA256" ]]; then
    echo "Invalid checksum for official phpList $UPSTREAM_PACKAGE_VERSION package." >&2
    exit 1
fi

if [[ ! -f "$UPSTREAM_LISTS/base/vendor/autoload.php" ]]; then
    echo "Missing complete upstream package: $UPSTREAM_LISTS" >&2
    echo "Use the verified SourceForge production archive for phpList $UPSTREAM_PACKAGE_VERSION." >&2
    exit 1
fi

mkdir -p "$COMMON_LISTS"

rsync -a --delete --delete-excluded \
    --exclude '.DS_Store' \
    --exclude 'Thumbs.db' \
    --exclude 'config/config.php' \
    --exclude 'admin/plugins/' \
    "$UPSTREAM_LISTS/" "$COMMON_LISTS/"

# The production package contains generated release files (notably init.php and
# structure.php) that must not be replaced by their development-tree variants.
# Overlay only the two post-package upstream security fixes, the PHP 8.2 CSV
# compatibility fix and the five common NFS customizations audited for 3.7.0.
source_overlays=(
    "admin/bouncerules.php"
    "admin/massremove.php"
    "admin/CsvReader.php"
    "admin/connect.php"
    "admin/lib.php"
    "admin/pluginlib.php"
    "admin/spageedit.php"
    "index.php"
)

for relative_path in "${source_overlays[@]}"; do
    mkdir -p "$(dirname "$COMMON_LISTS/$relative_path")"
    rsync -a "$ROOT_DIR/public_html/lists/$relative_path" "$COMMON_LISTS/$relative_path"
done

rsync -a "$ROOT_DIR/VERSION" "$COMMON_ROOT/VERSION"

(
    cd "$COMMON_ROOT"
    find . -type f -print0 | xargs -0 shasum -a 256 | LC_ALL=C sort
) >"$MANIFEST"

printf 'Built %s from verified production %s + audited source overlays (%s files)\n' \
    "$COMMON_ROOT" \
    "$UPSTREAM_PACKAGE_VERSION" \
    "$(wc -l <"$MANIFEST" | tr -d ' ')"
