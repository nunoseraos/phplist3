#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARTIFACT_ROOT="$ROOT_DIR/.artifacts"
segurosmais="$ARTIFACT_ROOT/phplist-3.6.17-segurosmais"
saldo="$ARTIFACT_ROOT/phplist-3.6.17-simulacaocreditopessoal"
segurosmais_url="https://segurosmais.pt/pagina-subscricao-newsletter-simulacoes/"
saldo_url="https://saldo.pt/simuladores/obrigado-confirmacao"

fail() {
    echo "FAIL  $1" >&2
    exit 1
}

for artifact in "$segurosmais" "$saldo"; do
    [[ -f "$artifact/VERSION" ]] || fail "$artifact has no VERSION"
    grep -Fq 'VERSION=3.6.17' "$artifact/VERSION" || fail "$artifact has the wrong VERSION"
    [[ -f "$artifact/public_html/lists/index.php" ]] || fail "$artifact has no public index"
    [[ -f "$artifact/public_html/lists/admin/index.php" ]] || fail "$artifact has no admin index"
    [[ ! -e "$artifact/public_html/lists/config/config.php" ]] || fail "$artifact contains deployable config.php"
    [[ ! -e "$artifact/public_html/lists/config/config_extended.php" ]] || fail "$artifact contains deployable config_extended.php"
done

segurosmais_plugin="$segurosmais/public_html/lists/admin/plugins/NFSCustomizationsPlugin.php"
saldo_plugin="$saldo/public_html/lists/admin/plugins/NFSCustomizationsPlugin.php"

cmp -s "$segurosmais_plugin" "$ROOT_DIR/deploy/segurosmais/public_html/lists/admin/plugins/NFSCustomizationsPlugin.php" \
    || fail "SegurosMais artefact does not contain its exact overlay"
cmp -s "$saldo_plugin" "$ROOT_DIR/deploy/simulacaocreditopessoal/public_html/lists/admin/plugins/NFSCustomizationsPlugin.php" \
    || fail "Saldo artefact does not contain its exact overlay"

grep -Fq "$segurosmais_url" "$segurosmais_plugin" || fail "SegurosMais destination is absent"
! grep -Fq "$saldo_url" "$segurosmais_plugin" || fail "SegurosMais artefact contains the Saldo destination"
grep -Fq "$saldo_url" "$saldo_plugin" || fail "Saldo destination is absent"
! grep -Fq "$segurosmais_url" "$saldo_plugin" || fail "Saldo artefact contains the SegurosMais destination"

[[ -s "$ARTIFACT_ROOT/phplist-3.6.17-segurosmais.sha256" ]] || fail "SegurosMais manifest is absent"
[[ -s "$ARTIFACT_ROOT/phplist-3.6.17-simulacaocreditopessoal.sha256" ]] || fail "Saldo manifest is absent"

echo "site artefacts ok"
