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
# 加 UTF-8 BOM，舊版 Windows 記事本才不會亂碼
{ printf '\xEF\xBB\xBF'; cat docs/使用說明.txt; } > "dist/${name}/使用說明.txt"
cp docs/規定與計算邏輯檢查.md "dist/${name}/規定與計算邏輯檢查.md"
cp CHANGELOG.md "dist/${name}/更新日誌.md"
# 用 Python 打包：中文檔名會標記為 UTF-8，Windows 檔案總管才能正確顯示與解壓縮
python3 - "dist/${name}" <<'PY'
import os, sys, zipfile
src = sys.argv[1]
base = os.path.dirname(src)
with zipfile.ZipFile(src + '.zip', 'w', zipfile.ZIP_DEFLATED) as z:
    for root, _, files in os.walk(src):
        for f in sorted(files):
            full = os.path.join(root, f)
            z.write(full, os.path.relpath(full, base))
PY
rm -rf "dist/${name}"
ls -l dist version.json
