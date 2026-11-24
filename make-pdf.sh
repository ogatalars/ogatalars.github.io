#!/usr/bin/env bash
# Regera os PDFs (PT/EN) a partir do index.html. Rode após editar o conteúdo.
set -euo pipefail
cd "$(dirname "$0")"
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
cp style.css "$tmp/"
chrome=$(command -v google-chrome || command -v chromium || command -v chromium-browser)
for l in pt en; do
  sed -e "s/localStorage.getItem('theme') || 'c'/'c'/" -e "s/localStorage.getItem('lang') || 'pt'/'$l'/" index.html > "$tmp/$l.html"
  grep -q "dataset.lang = '$l'" "$tmp/$l.html" || { echo "padrão do sed não casou" >&2; exit 1; }
  "$chrome" --headless=new --disable-gpu --no-pdf-header-footer --virtual-time-budget=6000 \
    --print-to-pdf="$PWD/felipe-ogata-cv-$l.pdf" "file://$tmp/$l.html" 2>/dev/null
done
ls -la felipe-ogata-cv-*.pdf
