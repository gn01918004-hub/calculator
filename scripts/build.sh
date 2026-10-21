#!/usr/bin/env bash
# 產生可散佈檔案：dist/囑託測量收費試算_<版本>.html 與同名 .zip
set -euo pipefail
cd "$(dirname "$0")/.."
ver=$(grep -oP "const VERSION = '\Kv[0-9.]+" index.html)
name="囑託測量收費試算_${ver}"
rm -rf dist && mkdir -p "dist/${name}"
cp index.html "dist/${name}.html"
cp index.html "dist/${name}/${name}.html"
cp docs/使用說明.txt "dist/${name}/使用說明.txt"
cp docs/規定與計算邏輯檢查.md "dist/${name}/規定與計算邏輯檢查.md"
(cd dist && zip -qr "${name}.zip" "${name}" && rm -rf "${name}")
ls -l dist
