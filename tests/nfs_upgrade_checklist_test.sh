#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_FILE="$(mktemp)"
trap 'rm -f "$OUTPUT_FILE"' EXIT

if ! "$ROOT_DIR/scripts/nfs-upgrade-checklist.sh" "legacy/__missing_baseline__" >"$OUTPUT_FILE"; then
    echo "FAIL  an optional missing legacy snapshot made the current-tree checklist fail" >&2
    cat "$OUTPUT_FILE" >&2
    exit 1
fi

grep -Fq "MISS  legacy/__missing_baseline__/index.php" "$OUTPUT_FILE"
grep -Fq "OK    public_html/lists/index.php" "$OUTPUT_FILE"
grep -Fq "OK    deploy/segurosmais/lists/admin/plugins/NFSCustomizationsPlugin.php" "$OUTPUT_FILE"
grep -Fq "OK    deploy/simulacaocreditopessoal/lists/admin/plugins/NFSCustomizationsPlugin.php" "$OUTPUT_FILE"
grep -Fq "OK    deploy/saldo/lists/admin/plugins/NFSCustomizationsPlugin.php" "$OUTPUT_FILE"

echo "upgrade checklist behavior ok"
