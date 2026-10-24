#!/bin/zsh
# Usage: scripts/selftest.sh index.html  (headless Chrome runs index.html#test and prints the results)
f=${1:?usage: selftest.sh path/to/index.html}
f=${f:A}
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless=new --disable-gpu --no-first-run --user-data-dir=$(mktemp -d) --virtual-time-budget=15000 --dump-dom "file://$f#test" 2>/dev/null | python3 -c "
import sys,re,html,json
m=re.search(r'<pre id=\"selftest\"[^>]*>(.*?)</pre>',sys.stdin.read(),re.S)
if not m or not m.group(1).strip(): print('FAIL: NO OUTPUT (runSelfTest threw?)'); sys.exit(1)
d=json.loads(html.unescape(m.group(1)))
print('OK' if d['ok'] else 'FAIL', 'passed', d['passed'])
for f in d['failed']: print('  FAIL %s: %s' % (f['name'], f['error']))
sys.exit(0 if d['ok'] else 1)
"
