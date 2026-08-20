#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

LEGACY_DIR="${1:-legacy/v3.6.14}"
STATUS=0

legacy_files=(
  "index.php"
  "admin/subscribelib2.php"
  "admin/reconcileusers.php"
  "admin/reconcile.php"
  "admin/connect.php"
  "admin/sendemaillib.php"
  "admin/ui/phplist-ui-bootlist/css/style.css"
  "config/config.php"
)

target_files=(
  "public_html/lists/index.php"
  "public_html/lists/admin/subscribelib2.php"
  "public_html/lists/admin/reconcileusers.php"
  "public_html/lists/admin/connect.php"
  "public_html/lists/admin/sendemaillib.php"
  "public_html/lists/admin/ui/default/css/style.css"
  "public_html/lists/config/config.php"
  "public_html/lists/config/config_extended.php"
)

plugin_files=(
  "deploy/segurosmais/lists/admin/plugins/NFSCustomizationsPlugin.php"
  "deploy/segurosmais/lists/admin/plugins/NFSCustomizationsPlugin/nfs_shortcuts.php"
  "deploy/simulacaocreditopessoal/lists/admin/plugins/NFSCustomizationsPlugin.php"
  "deploy/simulacaocreditopessoal/lists/admin/plugins/NFSCustomizationsPlugin/nfs_shortcuts.php"
  "deploy/saldo/lists/admin/plugins/NFSCustomizationsPlugin.php"
  "deploy/saldo/lists/admin/plugins/NFSCustomizationsPlugin/nfs_shortcuts.php"
)

hook_checks=(
  "public_html/lists/admin/subscribelib2.php|validateSubscriptionPage"
  "public_html/lists/admin/subscribelib2.php|parseThankyou"
  "public_html/lists/admin/sendemaillib.php|parseOutgoingTextMessage"
  "public_html/lists/admin/sendemaillib.php|parseOutgoingHTMLMessage"
  "public_html/lists/admin/connect.php|topMenuLinks"
  "public_html/lists/admin/connect.php|NFS quick links kept in the sidebar"
  "public_html/lists/admin/lib.php|Skipping login notification for admin"
  "public_html/lists/admin/pluginlib.php|NFSCustomizationsPlugin"
  "public_html/lists/admin/spageedit.php|hidePostConfirmationMessageFields"
  "deploy/segurosmais/lists/admin/plugins/NFSCustomizationsPlugin.php|autoSuppressHardFailuresFromEventLog"
  "deploy/segurosmais/lists/admin/plugins/NFSCustomizationsPlugin.php|monitorQueueHealthAndNotify"
  "deploy/segurosmais/lists/admin/plugins/NFSCustomizationsPlugin.php|subscriberConfirmation("
  "deploy/segurosmais/lists/admin/plugins/NFSCustomizationsPlugin.php|confirmationRedirectUrl("
  "deploy/segurosmais/lists/admin/plugins/NFSCustomizationsPlugin.php|hidePostConfirmationMessageFields("
  "deploy/segurosmais/lists/admin/plugins/NFSCustomizationsPlugin.php|shouldSuppressPostConfirmMail("
  "deploy/segurosmais/lists/admin/plugins/NFSCustomizationsPlugin.php|NFS_SUPPRESS_POST_CONFIRMATION_EMAIL"
  "public_html/lists/index.php|confirmationRedirectUrl"
  "deploy/segurosmais/lists/admin/plugins/NFSCustomizationsPlugin.php|https://segurosmais.pt/pagina-subscricao-newsletter-simulacoes/"
  "deploy/simulacaocreditopessoal/lists/admin/plugins/NFSCustomizationsPlugin.php|https://saldo.pt/simuladores/obrigado-confirmacao"
  "deploy/saldo/lists/admin/plugins/NFSCustomizationsPlugin.php|https://saldo.pt/simuladores/obrigado-confirmacao"
)

echo "== Legacy baseline (${LEGACY_DIR}) =="
for file in "${legacy_files[@]}"; do
  path="${LEGACY_DIR}/${file}"
  if [[ -f "$path" ]]; then
    printf 'OK    %s\n' "$path"
  else
    printf 'MISS  %s\n' "$path"
  fi
done

echo
echo "== Current target paths =="
for file in "${target_files[@]}"; do
  if [[ -f "$file" ]]; then
    printf 'OK    %s\n' "$file"
  else
    printf 'MISS  %s\n' "$file"
    STATUS=1
  fi
done

echo
echo "== Plugin files =="
for file in "${plugin_files[@]}"; do
  if [[ -f "$file" ]]; then
    printf 'OK    %s\n' "$file"
  else
    printf 'MISS  %s\n' "$file"
    STATUS=1
  fi
done

echo
echo "== Hook anchors in current phpList =="
for check in "${hook_checks[@]}"; do
  file="${check%%|*}"
  pattern="${check##*|}"
  if grep -q "$pattern" "$file"; then
    printf 'OK    %s :: %s\n' "$file" "$pattern"
  else
    printf 'MISS  %s :: %s\n' "$file" "$pattern"
    STATUS=1
  fi
done

echo
echo "== Notes =="
if [[ -f "public_html/lists/admin/reconcile.php" ]]; then
  echo "INFO  public_html/lists/admin/reconcile.php exists in this checkout."
else
  echo "INFO  public_html/lists/admin/reconcile.php is absent (expected in current tree)."
fi

if [[ -f "${LEGACY_DIR}/config/config.php" ]]; then
  echo "WARN  ${LEGACY_DIR}/config/config.php may contain secrets. Keep it private/sanitized."
fi

echo
cat <<'EOF'
== Manual upgrade steps ==
1. Sync upstream on main and update custom branch.
2. Run this checklist script.
3. Run tests/run-nfs-site-overlays-test.sh.
4. Generate deploy/common and apply exactly one of the three site overlays.
5. Ensure the site-specific "NFS Customizations" plugin is enabled in phpList admin.
6. Execute end-to-end tests:
   - subscribe + ajax subscribe
   - confirm email click
   - confirm click must NOT send confirmationsubject/confirmationmessage for NFS pages
   - subscribe page editor hides the post-confirmation message fields for NFS pages
   - reconcile resend-confirm
   - test campaign message output
7. Operational safety checks in production config:
   - queue/bounce cron are active (processqueue + processbounces)
   - each admin has a valid email, or notify_admin_login is disabled
EOF

exit "$STATUS"
