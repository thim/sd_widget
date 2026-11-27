#!/usr/bin/env bash
# Copia o contrato SDUI v1 do kanvas para test/contract/sdui/v1.
#
#   tool/sync_contract.sh [ref]     # ref = branch, tag ou commit do kanvas (padrão: main)
#
# O kanvas é a fonte da verdade do contrato; não edite os arquivos copiados aqui.
set -euo pipefail

REF="${1:-main}"
REPO="thim/kanvas"
DEST="$(cd "$(dirname "$0")/.." && pwd)/test/contract/sdui/v1"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

curl -fsSL "https://codeload.github.com/${REPO}/tar.gz/${REF}" | tar -xz -C "$TMP"
SRC="$(find "$TMP" -maxdepth 4 -type d -path '*/contracts/sdui/v1' | head -1)"
[ -n "$SRC" ] || { echo "contracts/sdui/v1 não encontrado em ${REPO}@${REF}" >&2; exit 1; }

rm -rf "$DEST"
mkdir -p "$DEST"
cp -R "$SRC"/. "$DEST"/
echo "${REPO}@${REF}" > "$DEST/SOURCE"
echo "Contrato copiado de ${REPO}@${REF} para ${DEST}"
