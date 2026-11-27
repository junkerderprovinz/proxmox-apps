"""Builds the README's app list from the cards in junkerderprovinz/unraid-apps.

Each app keeps the icon, description and group (Apps, Images, Wrappers) it has
in unraid-apps, so the store READMEs cannot drift apart. apps.json says which
of the three ways in an app takes.

    python tools/readme.py ../unraid-apps          write the list
    python tools/readme.py ../unraid-apps --check  fail if it is stale
"""

import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FEED_URL = "https://github.com/junkerderprovinz/unraid-apps"

ROUTES = {
    "script": ("Script", "#3-install-with-a-script"),
    "image": ("Image", "#4-run-the-image"),
    "docker": ("Docker", "#5-run-it-with-docker"),
}


def cards(feed, apps):
    source = (feed / "README.md").read_text(encoding="utf-8")
    groups = {}
    for app in sorted(apps):
        start = source.index(f'<img src=".github/readme-icons/{app}.png"')
        card = source[start:source.index('<br clear="all">', start)]
        heading = list(re.finditer(r"^## (\w+)\n\n(\*.+\*)$", source[:start], re.M))[-1]
        icon = card.split("\n", 1)[0]
        name, repo, description = re.search(r"^\*\*\[(.+?)\]\((.+?)\)\*\*.*?<br>\n(.+?)\s*$", card, re.M | re.S).groups()
        repo = re.sub(r"^([\w-]+/README\.md)$", rf"{FEED_URL}/blob/main/\1", repo)
        ways = "".join(f" · [{label}]({href})" for label, href in (ROUTES[r] for r in apps[app]))
        body = f'<a id="{app}"></a>\n{icon}\n\n**[{name}]({repo})**{ways}<br>\n{description}\n\n<br clear="all">'
        groups.setdefault(heading.group(1), (heading.group(2), []))[1].append(body)
    order = [h for h in ("Apps", "Images", "Wrappers") if h in groups]
    return "\n\n\n".join(f"### {h}\n\n{groups[h][0]}\n\n" + "\n\n".join(groups[h][1]) for h in order)


def main():
    parser = argparse.ArgumentParser(description="Write the README's app list from unraid-apps.")
    parser.add_argument("feed", type=Path, help="checkout of junkerderprovinz/unraid-apps")
    parser.add_argument("--check", action="store_true", help="report a stale list instead of writing")
    args = parser.parse_args()

    apps = json.loads((ROOT / "apps.json").read_text(encoding="utf-8"))
    icons = args.feed / ".github" / "readme-icons"
    wanted = {f".github/readme-icons/{app}.png": (icons / f"{app}.png").read_bytes() for app in apps}
    current = (ROOT / "README.md").read_text(encoding="utf-8")
    wanted["README.md"] = re.sub(
        r"(<!-- apps:start -->\n).*?(<!-- apps:end -->)",
        lambda m: m.group(1) + cards(args.feed, apps) + "\n" + m.group(2),
        current,
        flags=re.S,
    ).encode("utf-8")

    stale = [n for n, content in wanted.items() if not (ROOT / n).exists() or (ROOT / n).read_bytes() != content]
    present = {p.relative_to(ROOT).as_posix() for p in (ROOT / ".github" / "readme-icons").glob("*.png")}
    removed = sorted(present - wanted.keys())
    if args.check:
        if stale or removed:
            print("out of date: " + ", ".join(stale + removed), file=sys.stderr)
            print("run: python tools/readme.py <unraid-apps checkout>", file=sys.stderr)
            return 1
        return 0
    for name in stale:
        (ROOT / name).parent.mkdir(parents=True, exist_ok=True)
        (ROOT / name).write_bytes(wanted[name])
        print(f"updated {name}")
    for name in removed:
        (ROOT / name).unlink()
        print(f"removed {name}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
