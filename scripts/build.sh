#!/usr/bin/env bash
# 產生可散佈檔案 dist/囑託測量收費試算_<版本>.html、同名 .zip，以及給自動更新讀的 version.json
# 版本資料來源：index.html 裡 <script id="changelogData"> 的 JSON（最新版本放最前面）
set -euo pipefail
cd "$(dirname "$0")/.."
ver=$(python3 - <<'EOF'
import json, re, urllib.parse
html = open('index.html', encoding='utf-8').read()
m = re.search(r'<script type="application/json" id="changelogData">\s*(.*?)\s*</script>', html, re.S)
cl = json.loads(m.group(1))
v = cl['versions'][0]
name = f"囑託測量收費試算_v{v['version']}"
info = {
    'version': v['version'],
    'date': v['date'],
    'title': v['title'],
    'items': v['items'],
    'download': 'https://github.com/gn01918004-hub/calculator/blob/HEAD/dist/' + urllib.parse.quote(name + '.html'),
}
with open('version.json', 'w', encoding='utf-8') as f:
    json.dump(info, f, ensure_ascii=False, indent=2)
    f.write('\n')
print(v['version'])
EOF
)
name="囑託測量收費試算_v${ver}"
rm -rf dist && mkdir -p "dist/${name}"
cp index.html "dist/${name}.html"
cp index.html "dist/${name}/${name}.html"
cp docs/使用說明.txt "dist/${name}/使用說明.txt"
cp docs/規定與計算邏輯檢查.md "dist/${name}/規定與計算邏輯檢查.md"
cp CHANGELOG.md "dist/${name}/更新日誌.md"
(cd dist && zip -qr "${name}.zip" "${name}" && rm -rf "${name}")
ls -l dist version.json
