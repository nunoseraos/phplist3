#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMMON="$ROOT_DIR/deploy/common"
SEGUROSMAIS="$ROOT_DIR/deploy/segurosmais"
SALDO="$ROOT_DIR/deploy/saldo"
COMMON_LISTS="$COMMON/root/lists"

fail() {
    echo "FAIL  $1" >&2
    exit 1
}

[[ -f "$COMMON/VERSION" ]] || fail "common deploy has no VERSION"
grep -Fq 'VERSION=3.7.0' "$COMMON/VERSION" || fail "common deploy has the wrong VERSION"
[[ -f "$COMMON_LISTS/index.php" ]] || fail "common deploy has no public index"
[[ -f "$COMMON_LISTS/admin/index.php" ]] || fail "common deploy has no admin index"
[[ -f "$COMMON_LISTS/base/vendor/autoload.php" ]] || fail "common deploy lacks production vendor dependencies"
[[ -d "$COMMON_LISTS/admin/ui/phplist-ui-bootlist" ]] || fail "common deploy lacks the production admin UI"
[[ ! -e "$COMMON_LISTS/config/config.php" ]] || fail "common deploy contains a site config.php"
[[ -f "$COMMON_LISTS/config/config_extended.php" ]] || fail "common deploy lost the upstream config reference"
[[ ! -e "$COMMON_LISTS/admin/plugins" ]] || fail "common deploy contains site-specific plugins"
[[ -s "$ROOT_DIR/deploy/common.sha256" ]] || fail "common deploy manifest is absent"

for overlay in "$SEGUROSMAIS" "$SALDO"; do
    [[ -f "$overlay/lists/admin/plugins/NFSCustomizationsPlugin.php" ]] \
        || fail "$overlay has no plugin"
    [[ -f "$overlay/lists/admin/plugins/NFSCustomizationsPlugin/nfs_shortcuts.php" ]] \
        || fail "$overlay has no plugin shortcuts"
    [[ -f "$overlay/lists/admin/plugins/CommonPlugin.php" ]] \
        || fail "$overlay has no production CommonPlugin"
    [[ -f "$overlay/lists/admin/plugins/CKEditorPlugin.php" ]] \
        || fail "$overlay has no production CKEditorPlugin"
    [[ -f "$overlay/lists/config/config.php.example" ]] \
        || fail "$overlay has no config.php.example"
done

[[ ! -e "$SALDO/lists/index.php" ]] || fail "Saldo overlay contains a stale common index.php"
[[ ! -e "$SALDO/lists/.htaccess" ]] || fail "Saldo overlay contains a redundant common .htaccess"

echo "common core and the two operational site overlays ok"
