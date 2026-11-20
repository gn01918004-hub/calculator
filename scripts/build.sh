#!/usr/bin/env bash
# 產生發布用檔案：
#   dist/survey-fee-calculator.html  Release 附件（檔名固定、不含版本號）
#   dist/release-notes.md            Release 說明（本版更新項目）
#   version.json                     給程式自動檢查更新讀取（需 commit）
# 版本資料來源：index.html 裡 <script id="changelogData"> 的 JSON（最新版本放最前面）
# 實際發布由 .github/workflows/release.yml 在 push 後自動執行
set -euo pipefail
cd "$(dirname "$0")/.."
rm -rf dist && mkdir -p dist
python3 - <<'EOF'
import json, re
REPO = 'gn01918004-hub/calculator'
ASSET = 'survey-fee-calculator.html'
html = open('index.html', encoding='utf-8').read()
m = re.search(r'<script type="application/json" id="changelogData">\s*(.*?)\s*</script>', html, re.S)
v = json.loads(m.group(1))['versions'][0]
download = f'https://github.com/{REPO}/releases/latest/download/{ASSET}'
info = {'version': v['version'], 'date': v['date'], 'title': v['title'], 'items': v['items'], 'download': download}
with open('version.json', 'w', encoding='utf-8') as f:
    json.dump(info, f, ensure_ascii=False, indent=2)
    f.write('\n')
lines = [f"**{v['title']}**（{v['date']}）", '']
lines += [f'- {k}：{t}' for k, t in v['items']]
lines += ['', f'下載：[{ASSET}]({download})', '',
          '更新方式：先在舊版按「📁 檔案 → 下載備份（全部案件）」，再用新檔取代舊檔，用同一個瀏覽器開啟，原本的資料會保留。',
          '', '完整更新紀錄見 [CHANGELOG.md](https://github.com/' + REPO + '/blob/HEAD/CHANGELOG.md)。']
open('dist/release-notes.md', 'w', encoding='utf-8').write('\n'.join(lines) + '\n')
open('dist/version.txt', 'w').write(v['version'] + '\n')
EOF
cp index.html dist/survey-fee-calculator.html
echo "v$(cat dist/version.txt)"
ls -l dist version.json
