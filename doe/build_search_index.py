#!/usr/bin/env python3
"""
build_search_index.py - build the examples index used by the search page.

    python3 build_search_index.py /path/to/examples

Reads every .ck file under the folder and writes one JSON file. By default it
goes in ../search/examples.json, found relative to THIS SCRIPT (not to where
you run it from), so a script kept in /doc/ writes into the site's /search/
folder. The folder must already exist. It never goes into the examples
folder, which ships with the software. Use --out to write somewhere else.
Re-run it whenever you add, edit or remove an example.

The output is deterministic (no timestamps), so if nothing changed the file
is left untouched and your uploads/commits stay quiet.
"""
import argparse
import gzip
import json
import sys
from pathlib import Path

INDEX_VERSION = 1  # the search page checks this; bump both if the format changes


def is_excluded(parts, excludes):
    """True if any excluded folder (name or a/b path) appears in the path parts."""
    for ex in excludes:
        ex = [p for p in ex.replace("\\", "/").split("/") if p]
        n = len(ex)
        if n and any(list(parts[i:i + n]) == ex for i in range(len(parts) - n + 1)):
            return True
    return False


def read_text(path):
    raw = path.read_bytes()
    try:
        text = raw.decode("utf-8-sig")
    except UnicodeDecodeError:
        print(f"warning: {path} is not UTF-8, reading it as Latin-1")
        text = raw.decode("latin-1")
    return text.replace("\r\n", "\n").replace("\r", "\n")


def mb(n):
    return f"{n / 1024:.0f} KB" if n < 1024 * 1024 else f"{n / 1024 / 1024:.2f} MB"


def main():
    ap = argparse.ArgumentParser(description="Build the examples index (examples.json) for the search page.")
    ap.add_argument("folder", type=Path, help="examples folder to search recursively for .ck files")
    ap.add_argument("--out", type=Path,
                    help="output file (default: ../search/examples.json, relative to this script)")
    ap.add_argument("--exclude", action="append", default=[], metavar="DIR",
                    help="leave a folder out of the index, by name or path such as osc/multicast (repeatable)")
    ap.add_argument("--dry-run", action="store_true", help="report sizes, write nothing")
    args = ap.parse_args()

    root = args.folder
    if not root.is_dir():
        sys.exit(f"Not a folder: {root}")
    out = args.out or Path(__file__).resolve().parent.parent / "search" / "examples.json"
    if not out.parent.is_dir():
        sys.exit(f"The folder {out.parent} doesn't exist, so there's nowhere to write the index.\n"
                 "By default the index goes in ../search/ next to this script's folder. "
                 "Create that folder, or choose a location with --out.")

    examples = []
    for p in root.rglob("*"):
        rel = p.relative_to(root)
        if not p.is_file() or p.suffix.lower() != ".ck":
            continue
        if any(part.startswith(".") for part in rel.parts) or is_excluded(rel.parts[:-1], args.exclude):
            continue
        examples.append({
            "path": rel.as_posix(),                       # e.g. basic/sinosc.ck
            "page": p.with_suffix(".html").is_file(),     # does a web page exist next to it?
            "code": read_text(p).rstrip(),
        })
    if not examples:
        sys.exit("No .ck files found.")
    examples.sort(key=lambda e: (e["path"].lower(), e["path"]))

    data = json.dumps({"version": INDEX_VERSION, "count": len(examples), "examples": examples},
                      ensure_ascii=False, separators=(",", ":")).encode("utf-8")
    code_bytes = sum(len(e["code"].encode("utf-8")) for e in examples)
    no_page = [e["path"] for e in examples if not e["page"]]

    print(f"Indexed {len(examples)} examples ({mb(code_bytes)} of code).")
    print(f"{out}: {mb(len(data))}, about {mb(len(gzip.compress(data, 6)))} gzipped.")
    if no_page:
        print(f"{len(no_page)} have no .html page, so search results link to the .ck file itself"
              + (":" if len(no_page) <= 10 else " (first 10):"))
        for path in no_page[:10]:
            print(f"  {path}")

    if args.dry_run:
        print("Dry run: nothing written.")
    elif out.exists() and out.read_bytes() == data:
        print("Index already up to date.")
    else:
        out.write_bytes(data)
        print("Wrote index.")


if __name__ == "__main__":
    main()
