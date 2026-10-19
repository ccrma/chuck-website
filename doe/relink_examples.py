#!/usr/bin/env python3
"""
relink_examples.py - point <a href="....ck"> links at the matching .html page.

    python3 relink_examples.py /path/to/site

Scans every .html/.htm file under the folder and, in each <a> tag whose href
ends in .ck, changes the extension to .html. Only the href value is touched;
the rest of each file is preserved byte for byte. Re-running is harmless.

Left alone (and reported): links to other websites, links with a download
attribute, and links into folders you name with --keep-ck.
"""
import argparse
import re
import sys
from pathlib import Path
from urllib.parse import urlparse

ANCHOR = re.compile(r"<a\b[^>]*>", re.I | re.S)
HREF = re.compile(r"""(?<![\w-])href\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s"'>]+))""", re.I)
DOWNLOAD = re.compile(r"(?<![\w-])download(?=[\s=/>])", re.I)
QUOTED = re.compile(r"\"[^\"]*\"|'[^']*'")
CK_URL = re.compile(r"^([^?#]*)\.ck([?#].*)?$", re.I | re.S)


def is_excluded(parts, excludes):
    """True if any excluded folder (name or a/b path) appears in the path parts."""
    for ex in excludes:
        ex = [p for p in ex.replace("\\", "/").split("/") if p]
        n = len(ex)
        if n and any(list(parts[i:i + n]) == ex for i in range(len(parts) - n + 1)):
            return True
    return False


def target_dirs(page_dir_parts, url_path):
    """Folders the link points into, resolving ./ and ../ against the page's location."""
    out = [] if url_path.startswith("/") else list(page_dir_parts)
    for seg in url_path.split("/")[:-1]:
        if seg in ("", "."):
            continue
        if seg == "..":
            if out:
                out.pop()
        else:
            out.append(seg)
    return out


def main():
    ap = argparse.ArgumentParser(description="Point <a> links to .ck files at the matching .html pages.")
    ap.add_argument("folder", type=Path, help="site folder to scan recursively")
    ap.add_argument("--exclude", action="append", default=[], metavar="DIR",
                    help="don't edit pages inside this folder (name or path such as old/docs; repeatable)")
    ap.add_argument("--keep-ck", action="append", default=[], metavar="DIR",
                    help="leave links that point into this folder as .ck, e.g. folders with no web "
                         "version (name or path such as osc/multicast; repeatable)")
    ap.add_argument("--host", action="append", default=[], metavar="HOST",
                    help="treat absolute links to this host as local, e.g. chuck.stanford.edu (repeatable)")
    ap.add_argument("--ext", nargs="+", default=[".html", ".htm"],
                    help="file extensions to scan (default: .html .htm)")
    ap.add_argument("--dry-run", action="store_true", help="show what would change, write nothing")
    args = ap.parse_args()

    root = args.folder
    if not root.is_dir():
        sys.exit(f"Not a folder: {root}")
    exts = {e.lower() if e.startswith(".") else "." + e.lower() for e in args.ext}
    hosts = {h.lower() for h in args.host}

    changed = []                                   # (page, old, new)
    left = {"external": [], "download": [], "kept": []}
    files_changed = {}

    for page in sorted(root.rglob("*")):
        rel = page.relative_to(root)
        if not page.is_file() or page.suffix.lower() not in exts:
            continue
        if any(part.startswith(".") for part in rel.parts) or is_excluded(rel.parts[:-1], args.exclude):
            continue

        raw = page.read_bytes()
        try:
            text, enc = raw.decode("utf-8"), "utf-8"
        except UnicodeDecodeError:
            text, enc = raw.decode("latin-1"), "latin-1"

        def fix(m):
            tag = m.group(0)
            h = HREF.search(tag)
            if not h:
                return tag
            g = next(i for i in (1, 2, 3) if h.group(i) is not None)
            url = h.group(g).strip()
            ck = CK_URL.match(url)
            if not ck:
                return tag
            parsed = urlparse(url)
            if (parsed.scheme or parsed.netloc) and parsed.netloc.lower() not in hosts:
                left["external"].append((rel, url))
                return tag
            if DOWNLOAD.search(QUOTED.sub('""', tag)):
                left["download"].append((rel, url))
                return tag
            if is_excluded(target_dirs(rel.parts[:-1], parsed.path), args.keep_ck):
                left["kept"].append((rel, url))
                return tag
            new = ck.group(1) + ".html" + (ck.group(2) or "")
            changed.append((rel, url, new))
            files_changed[rel] = files_changed.get(rel, 0) + 1
            start, end = h.span(g)
            return tag[:start] + new + tag[end:]

        new_text = ANCHOR.sub(fix, text)
        if new_text != text and not args.dry_run:
            page.write_bytes(new_text.encode(enc))

    verb = "Would change" if args.dry_run else "Changed"
    print(f"{verb} {len(changed)} links in {len(files_changed)} files.")
    if args.dry_run:
        for rel, old, new in changed:
            print(f"  {rel}: {old} -> {new}")
    else:
        for rel, n in files_changed.items():
            print(f"  {rel} ({n})")

    labels = {"external": "links to other websites (use --host if any are really yours)",
              "download": "links with a download attribute",
              "kept": "links into --keep-ck folders"}
    for key, label in labels.items():
        if left[key]:
            print(f"\nLeft as .ck, {label}:")
            for rel, url in left[key]:
                print(f"  {rel}: {url}")


if __name__ == "__main__":
    main()
