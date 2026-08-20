#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
php_image="php:7.2-cli"

run_variant() {
    local plugin_path="$1"
    local confirmation_url="$2"
    local thankyou_page="$3"
    local thankyou_url="$4"
    local foreign_page="$5"

    docker run --rm \
        --volume "${repo_root}:/app:ro" \
        --workdir /app \
        "$php_image" \
        php tests/nfs_site_overlays_test.php \
        "$plugin_path" \
        "$confirmation_url" \
        "$thankyou_page" \
        "$thankyou_url" \
        "$foreign_page"
}

run_variant \
    deploy/segurosmais/lists/admin/plugins/NFSCustomizationsPlugin.php \
    https://segurosmais.pt/pagina-subscricao-newsletter-simulacoes/ \
    5 \
    https://segurosmais.pt/resultado/automovel/ \
    14

run_variant \
    deploy/simulacaocreditopessoal/lists/admin/plugins/NFSCustomizationsPlugin.php \
    https://saldo.pt/simuladores/obrigado-confirmacao \
    14 \
    https://creditosim.pt/resultado/credito-pessoal/ \
    5

run_variant \
    deploy/saldo/lists/admin/plugins/NFSCustomizationsPlugin.php \
    https://saldo.pt/simuladores/obrigado-confirmacao \
    14 \
    https://creditosim.pt/resultado/credito-pessoal/ \
    5
