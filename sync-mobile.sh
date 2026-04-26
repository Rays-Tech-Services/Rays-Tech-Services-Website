#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
SRC="$DIR/index.html"
DST="$DIR/mobile.html"

echo "Syncing $(basename "$SRC") → $(basename "$DST")..."

python3 - "$SRC" "$DST" << 'PYEOF'
import sys, re

src, dst = sys.argv[1], sys.argv[2]
with open(src, 'r') as f:
    c = f.read()

# 1. Remove cursor: none from body
c = c.replace('  cursor: none;\n', '')

# 2. Remove the entire /* CUSTOM CURSOR */ CSS block
c = re.sub(
    r'/\* CUSTOM CURSOR \*/\n.+?body:hover \.cursor \{ opacity: 1; \}\n',
    '',
    c, flags=re.DOTALL
)

# 3. Inject mobile hover-disable overrides before /* NOISE OVERLAY */
overrides = (
    '/* DISABLE HOVER ANIMATIONS ON MOBILE */\n'
    '.btn-blue:hover, .btn-outline:hover { transform: none !important; box-shadow: none !important; }\n'
    '.price-card:hover { transform: none !important; }\n'
    '.price-cta-filled:hover { transform: none !important; box-shadow: none !important; }\n'
    '.service-card:hover { background: var(--card) !important; }\n'
    '.service-card:hover::before { opacity: 0 !important; }\n\n'
)
c = c.replace('/* NOISE OVERLAY */', overrides + '/* NOISE OVERLAY */')

# 4. Remove cursor HTML elements
c = re.sub(
    r'<!-- CURSOR -->\n<div class="cursor" id="cursor"></div>\n<div class="cursor-ring" id="cursorRing"></div>\n\n',
    '',
    c
)

# 5. Remove mobile redirect JS block
c = re.sub(
    r'// MOBILE REDIRECT\nif \(.+?\}\n\n',
    '',
    c, flags=re.DOTALL
)

# 6. Remove cursor JS block (everything from // CURSOR up to // NAV SCROLL)
c = re.sub(
    r'// CURSOR\n.+?(?=// NAV SCROLL)',
    '',
    c, flags=re.DOTALL
)

with open(dst, 'w') as f:
    f.write(c)

print(f"  Done. mobile.html updated.")
PYEOF
