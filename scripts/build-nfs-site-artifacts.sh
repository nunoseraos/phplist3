#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION_NUMBER="$(sed -n 's/^VERSION=//p' "$ROOT_DIR/VERSION")"
ARTIFACT_ROOT="$ROOT_DIR/.artifacts"

if [[ "$VERSION_NUMBER" != "3.6.17" ]]; then
    echo "Refusing to build unexpected phpList version: $VERSION_NUMBER" >&2
    exit 1
fi

mkdir -p "$ARTIFACT_ROOT"

build_site() {
    local site="$1"
    local artifact="$ARTIFACT_ROOT/phplist-${VERSION_NUMBER}-${site}"
    local overlay="$ROOT_DIR/deploy/${site}"
    local manifest="$ARTIFACT_ROOT/phplist-${VERSION_NUMBER}-${site}.sha256"

    [[ -f "$overlay/public_html/lists/admin/plugins/NFSCustomizationsPlugin.php" ]] || {
        echo "Missing plugin overlay for $site" >&2
        exit 1
    }

    rm -rf "$artifact"
    mkdir -p "$artifact/public_html/lists"
    rsync -a --delete \
        --exclude '.DS_Store' \
        --exclude 'Thumbs.db' \
        "$ROOT_DIR/public_html/lists/" "$artifact/public_html/lists/"
    rsync -a "$overlay/" "$artifact/"
    cp "$ROOT_DIR/VERSION" "$artifact/VERSION"

    # Production configuration is restored from that site's private backup.
    rm -f \
        "$artifact/public_html/lists/config/config.php" \
        "$artifact/public_html/lists/config/config_extended.php"

    (
        cd "$artifact"
        find . -type f -exec shasum -a 256 {} \; | LC_ALL=C sort
    ) >"$manifest"

    printf 'Built %s (%s files)\n' "$artifact" "$(wc -l <"$manifest" | tr -d ' ')"
}

build_site "segurosmais"
build_site "simulacaocreditopessoal"
