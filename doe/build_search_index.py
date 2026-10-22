#!/usr/bin/env python3
"""
build_search_index.py - build the examples index used by the search page and
the random example button.

    python3 build_search_index.py [FOLDER]

Run it at the root of the site. It looks through FOLDER (default: the whole
site) for folders named "examples", at any depth, and reads every .ck file
inside them. For each one it records the code and whether an .html page sits
beside it. Everything goes into one JSON file, by default ../search/examples.json,
found relative to THIS SCRIPT, so a script kept in /doc/ writes into the
site's /search/ folder (which must already exist). Re-run it whenever you add,
edit or remove an example.

.ck files outside an "examples" folder are ignored. If FOLDER is itself inside
an examples folder (for example doc/examples/basic), that still counts.

The output is deterministic (no timestamps), so if nothing changed the file
is left untouched and your uploads/commits stay quiet.
"""
import argparse
import gzip
import json
import os
import sys
from pathlib import Path

INDEX_VERSION = 2  # the search page and random button check this; bump all three if the format changes


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


def size(n):
    return f"{n / 1024:.0f} KB" if n < 1024 * 1024 else f"{n / 1024 / 1024:.2f} MB"


def main():
    ap = argparse.ArgumentParser(description="Build the examples index (examples.json) for the search page.")
    ap.add_argument("folder", nargs="?", type=Path,
                    help="folder to look in for examples folders (default: the whole site root)")
    ap.add_argument("--site-root", type=Path, metavar="DIR",
                    help="the folder your server serves as / (default: the folder above this script's folder)")
    ap.add_argument("--folder-name", action="append", default=[], metavar="NAME",
                    help='name of the folders that hold examples (default: examples). Repeatable')
    ap.add_argument("--out", type=Path,
                    help="output file (default: ../search/examples.json, relative to this script)")
    ap.add_argument("--exclude", action="append", default=[], metavar="DIR",
                    help="skip a folder, by name or path such as old/docs, counted from FOLDER (repeatable)")
    ap.add_argument("--dry-run", action="store_true", help="report sizes, write nothing")
    args = ap.parse_args()

    script_dir = Path(__file__).resolve().parent
    site_root = (args.site_root or script_dir.parent).resolve()
    root = (args.folder or site_root).resolve()
    if not root.is_dir():
        sys.exit(f"Not a folder: {root}")
    try:
        root.relative_to(site_root)
    except ValueError:
        sys.exit(f"{root} isn't inside the site root {site_root}, so example addresses can't be worked out.\n"
                 "Pass --site-root with the folder your server serves as /.")

    out = args.out or script_dir.parent / "search" / "examples.json"
    if not out.parent.is_dir():
        sys.exit(f"The folder {out.parent} doesn't exist, so there's nowhere to write the index.\n"
                 "By default the index goes in ../search/ next to this script's folder. "
                 "Create that folder, or choose a location with --out.")

    names = {n.lower() for n in (args.folder_name or ["examples"])}
    examples, per_folder = [], {}
    for dirpath, dirnames, filenames in os.walk(root):
        here = Path(dirpath)
        from_root = here.relative_to(root).parts
        dirnames[:] = sorted(d for d in dirnames
                             if not d.startswith(".") and not is_excluded(from_root + (d,), args.exclude))
        site_parts = here.relative_to(site_root).parts
        found = next((i for i, part in enumerate(site_parts) if part.lower() in names), None)
        if found is None:
            continue                                   # not inside an examples folder
        examples_root = "/".join(site_parts[: found + 1])  # the outermost one, e.g. doc/examples
        inside = site_parts[found + 1:]
        for fname in sorted(filenames):
            if fname.startswith(".") or not fname.lower().endswith(".ck"):
                continue
            f = here / fname
            examples.append({
                "root": examples_root,                        # e.g. doc/examples
                "path": "/".join(inside + (fname,)),          # inside it, e.g. basic/sinosc.ck
                "page": f.with_suffix(".html").is_file(),     # does a web page exist next to it?
                "code": read_text(f).rstrip(),
            })
            per_folder[examples_root] = per_folder.get(examples_root, 0) + 1

    if not examples:
        sys.exit(f"No .ck files found inside folders named {', '.join(sorted(names))} under {root}.\n"
                 "Use --folder-name if your examples folders are called something else.")
    examples.sort(key=lambda e: (e["root"].lower(), e["path"].lower(), e["root"], e["path"]))

    data = json.dumps({"version": INDEX_VERSION, "count": len(examples), "examples": examples},
                      ensure_ascii=False, separators=(",", ":")).encode("utf-8")
    code_bytes = sum(len(e["code"].encode("utf-8")) for e in examples)
    no_page = [f"{e['root']}/{e['path']}" for e in examples if not e["page"]]

    print(f"Indexed {len(examples)} examples ({size(code_bytes)} of code) from "
          f"{len(per_folder)} examples folder{'s' if len(per_folder) != 1 else ''}:")
    for folder, count in sorted(per_folder.items()):
        print(f"  {folder} ({count})")
    print(f"{out}: {size(len(data))}, about {size(len(gzip.compress(data, 6)))} gzipped.")
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
