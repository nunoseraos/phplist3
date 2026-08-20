#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

status=0

assert_contains() {
    local file="$1"
    local pattern="$2"
    local label="$3"

    if grep -Fq "$pattern" "$file"; then
        printf 'OK    %s\n' "$label"
    else
        printf 'FAIL  %s (%s lacks %s)\n' "$label" "$file" "$pattern" >&2
        status=1
    fi
}

assert_contains "VERSION" "VERSION=3.6.17" "deployment version is 3.6.17"
assert_contains "public_html/lists/admin/admins.php" "verifyCsrfGetToken()" "admin deletion verifies its CSRF token"
assert_contains "public_html/lists/admin/bouncerules.php" "verifyToken()" "bounce-rule POST actions verify their token"
assert_contains "public_html/lists/admin/bouncerules.php" "verifyCsrfGetToken()" "bounce-rule deletion verifies its CSRF token"
assert_contains "public_html/lists/admin/bouncerules.php" "formStart('method=\"post\" class=\"bouncerulesAdd\"')" "new bounce-rule form emits a token"
assert_contains "public_html/lists/admin/massremove.php" "verifyCsrfGetToken()" "mass removal verifies its CSRF token"

assert_contains "public_html/lists/index.php" "subscriberConfirmation" "subscriber-confirmation hook remains installed"
assert_contains "public_html/lists/index.php" "confirmationRedirectUrl" "confirmation-redirect hook remains installed"
assert_contains "public_html/lists/admin/subscribelib2.php" "validateSubscriptionPage" "subscription validation hook remains installed"
assert_contains "public_html/lists/admin/subscribelib2.php" "parseThankyou" "post-submit redirect hook remains installed"
assert_contains "public_html/lists/admin/sendemaillib.php" "parseOutgoingTextMessage" "plain-text output hook remains installed"
assert_contains "public_html/lists/admin/sendemaillib.php" "parseOutgoingHTMLMessage" "HTML output hook remains installed"
assert_contains "public_html/lists/admin/spageedit.php" "hidePostConfirmationMessageFields" "subscribe-page editor hook remains installed"

segurosmais_plugin="deploy/segurosmais/public_html/lists/admin/plugins/NFSCustomizationsPlugin.php"
saldo_plugin="deploy/simulacaocreditopessoal/public_html/lists/admin/plugins/NFSCustomizationsPlugin.php"
segurosmais_url="https://segurosmais.pt/pagina-subscricao-newsletter-simulacoes/"
saldo_url="https://saldo.pt/simuladores/obrigado-confirmacao"

assert_contains "$segurosmais_plugin" "$segurosmais_url" "SegurosMais overlay has its fixed opt-in destination"
assert_contains "$saldo_plugin" "$saldo_url" "Saldo overlay has its fixed opt-in destination"

if grep -Fq "$saldo_url" "$segurosmais_plugin"; then
    echo "FAIL  SegurosMais overlay contains the Saldo opt-in destination" >&2
    status=1
else
    echo "OK    SegurosMais overlay excludes the Saldo opt-in destination"
fi

if grep -Fq "$segurosmais_url" "$saldo_plugin"; then
    echo "FAIL  Saldo overlay contains the SegurosMais opt-in destination" >&2
    status=1
else
    echo "OK    Saldo overlay excludes the SegurosMais opt-in destination"
fi

exit "$status"
