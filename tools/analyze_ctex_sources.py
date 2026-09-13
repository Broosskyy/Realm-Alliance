from pathlib import Path
from collections import defaultdict
import re

root = Path(__file__).resolve().parent.parent
ctex_size = {f.name: f.stat().st_size for f in (root / ".godot" / "imported").glob("*.ctex")}
by_src = defaultdict(int)
by_top = defaultdict(int)
for imp in root.rglob("*.import"):
    text = imp.read_text(encoding="utf-8", errors="ignore")
    src = None
    for line in text.splitlines():
        if line.startswith("source_file="):
            src = line.split("=", 1)[1].strip().strip('"')
    if not src or "res://.godot/imported/" not in text:
        continue
    m = re.search(r"res://\.godot/imported/([^\"]+)", text)
    if not m:
        continue
    sz = ctex_size.get(m.group(1), 0)
    if not sz:
        continue
    rel = src.replace("res://", "")
    top = rel.split("/")[0]
    by_top[top] += sz
    if rel.startswith("docs/"):
        cat = "docs"
    elif "_source_sheet" in rel:
        cat = "source_sheet"
    elif rel.startswith("assets/monsters/"):
        cat = "monsters"
    elif rel.startswith("assets/production/"):
        cat = "production"
    elif rel.startswith("assets/"):
        cat = "assets_other"
    else:
        cat = "other"
    by_src[cat] += sz

print("BY CATEGORY")
for k, v in sorted(by_src.items(), key=lambda x: -x[1]):
    print(k, round(v / 1024 / 1024, 1), "MiB")
print("BY TOP")
for k, v in sorted(by_top.items(), key=lambda x: -x[1]):
    print(k, round(v / 1024 / 1024, 1), "MiB")
