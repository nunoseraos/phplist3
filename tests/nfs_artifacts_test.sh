#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMMON="$ROOT_DIR/deploy/common"
SEGUROSMAIS="$ROOT_DIR/deploy/segurosmais"
SCP="$ROOT_DIR/deploy/simulacaocreditopessoal"
SALDO="$ROOT_DIR/deploy/saldo"

fail() {
    echo "FAIL  $1" >&2
    exit 1
}

[[ -f "$COMMON/VERSION" ]] || fail "common deploy has no VERSION"
grep -Fq 'VERSION=3.6.17' "$COMMON/VERSION" || fail "common deploy has the wrong VERSION"
[[ -f "$COMMON/lists/index.php" ]] || fail "common deploy has no public index"
[[ -f "$COMMON/lists/admin/index.php" ]] || fail "common deploy has no admin index"
[[ -f "$COMMON/lists/base/vendor/autoload.php" ]] || fail "common deploy lacks production vendor dependencies"
[[ -d "$COMMON/lists/admin/ui/phplist-ui-bootlist" ]] || fail "common deploy lacks the production admin UI"
[[ ! -e "$COMMON/lists/config/config.php" ]] || fail "common deploy contains a site config.php"
[[ -f "$COMMON/lists/config/config_extended.php" ]] || fail "common deploy lost the upstream config reference"
[[ ! -e "$COMMON/lists/admin/plugins" ]] || fail "common deploy contains site-specific plugins"
[[ -s "$ROOT_DIR/deploy/common.sha256" ]] || fail "common deploy manifest is absent"

for overlay in "$SEGUROSMAIS" "$SCP" "$SALDO"; do
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

cmp -s \
    "$SCP/lists/admin/plugins/NFSCustomizationsPlugin.php" \
    "$SALDO/lists/admin/plugins/NFSCustomizationsPlugin.php" \
    || fail "Saldo must initially use an independent copy of the SCP plugin"

echo "common core and three site overlays ok"
