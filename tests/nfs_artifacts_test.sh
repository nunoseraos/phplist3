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
grep -Fq 'define("VERSION","3.7.0")' "$COMMON_LISTS/admin/init.php" \
    || fail "common deploy replaced the generated production version with development detection"
grep -Fq "define('STRUCTUREVERSION',\"3.7.0\")" "$COMMON_LISTS/admin/structure.php" \
    || fail "common deploy replaced the generated production structure version"
[[ ! -e "$COMMON_LISTS/config/config.php" ]] || fail "common deploy contains a site config.php"
[[ -f "$COMMON_LISTS/config/config_extended.php" ]] || fail "common deploy lost the upstream config reference"
[[ ! -e "$COMMON_LISTS/admin/plugins" ]] || fail "common deploy contains site-specific plugins"
[[ ! -e "$COMMON_LISTS/admin/tests" ]] || fail "common deploy contains development-only admin tests"
[[ ! -e "$COMMON_LISTS/admin/ui/default" ]] || fail "common deploy contains the obsolete development UI"
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

compose_and_check() {
    local site="$1"
    local expected_url="$2"
    local foreign_url="$3"
    local composed

    composed="$(mktemp -d)"
    rsync -a "$COMMON_LISTS/" "$composed/lists/"
    rsync -a "$ROOT_DIR/deploy/$site/lists/" "$composed/lists/"

    [[ -f "$composed/lists/config/config.php" ]] || fail "$site composition has no private config.php"
    [[ -f "$composed/lists/admin/plugins/NFSCustomizationsPlugin.php" ]] \
        || fail "$site composition has no NFS plugin"
    grep -Fq "$expected_url" "$composed/lists/admin/plugins/NFSCustomizationsPlugin.php" \
        || fail "$site composition has the wrong confirmation URL"
    if grep -Fq "$foreign_url" "$composed/lists/admin/plugins/NFSCustomizationsPlugin.php"; then
        fail "$site composition contains the other site's confirmation URL"
    fi
    cmp -s "$COMMON_LISTS/index.php" "$composed/lists/index.php" \
        || fail "$site overlay replaces the audited common index.php"
    if rg -q "display_errors['\"],[[:space:]]*1|display_startup_errors['\"],[[:space:]]*1" "$composed/lists/index.php"; then
        fail "$site composition enables public PHP error display"
    fi
}

compose_and_check \
    "saldo" \
    "https://saldo.pt/simuladores/obrigado-confirmacao" \
    "https://segurosmais.pt/pagina-subscricao-newsletter-simulacoes/"
compose_and_check \
    "segurosmais" \
    "https://segurosmais.pt/pagina-subscricao-newsletter-simulacoes/" \
    "https://saldo.pt/simuladores/obrigado-confirmacao"

official_old="$(mktemp)"
official_new="$(mktemp)"
(cd "$ROOT_DIR/upstream-packages/phplist-3.6.17/public_html/lists" && \
    find . -type f ! -path './admin/plugins/*' ! -path './config/config.php' | LC_ALL=C sort) >"$official_old"
(cd "$ROOT_DIR/upstream-packages/phplist-3.7.0/public_html/lists" && \
    find . -type f ! -path './admin/plugins/*' ! -path './config/config.php' | LC_ALL=C sort) >"$official_new"
if comm -23 "$official_old" "$official_new" | rg -q .; then
    fail "official 3.6.17 package has obsolete core files not covered by deployment instructions"
fi

echo "common core and the two operational site overlays ok"
