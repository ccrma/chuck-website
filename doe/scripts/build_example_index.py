#!/usr/bin/env python3
"""
build_example_index.py - build the example search index.

    python3 build_example_index.py [FOLDER ...] [--out FILE] [--dry-run]

Reads every .ck file in the example folders (doc/examples and chugl/examples
by default) and writes search/examples.json for the search page. The code comes
from the .ck. Each result links to the example's .html page if it has one,
otherwise to the .ck file. Examples on the ignore list stay searchable; they
just link to the .ck, because they get no page.

The output has no timestamps, so an unchanged index isn't rewritten.
"""
import argparse
import gzip
import json
import sys
from pathlib import Path

import site_common as common

INDEX_VERSION = 2  # the search page checks this number; change both if the format changes


def main():
    ap = argparse.ArgumentParser(description="Build the example search index.")
    ap.add_argument("folders", nargs="*", type=Path,
                    help=f"example folders to read (default: {', '.join(common.EXAMPLE_FOLDERS)})")
    ap.add_argument("--out", type=Path, default=common.folder(common.SEARCH_FOLDER) / "examples.json",
                    help="where to write the index (default: %(default)s)")
    ap.add_argument("--dry-run", action="store_true", help="report what would be indexed; write nothing")
    args = ap.parse_args()

    folders = args.folders or [common.folder(name) for name in common.EXAMPLE_FOLDERS]
    if not args.out.parent.is_dir():
        sys.exit(f"The folder {args.out.parent} doesn't exist, so there's nowhere to write the index.")
    ignored = common.load_ignore_list()

    examples, per_folder = [], {}
    for folder in folders:
        if not folder.is_dir():
            print(f"warning: {folder} doesn't exist, skipping it")
            continue
        common.require_inside_site(folder)
        folder = folder.resolve()
        root = common.site_path(folder)                     # e.g. doc/examples
        for ck in common.find_files(folder, {".ck"}, skip=common.LEFT_OUT_FOLDERS):
            examples.append({
                "root": root,
                "path": ck.relative_to(folder).as_posix(),  # e.g. basic/sinosc.ck
                "page": common.has_page(ck, ignored),
                "code": common.read_text(ck).rstrip(),
            })
            per_folder[root] = per_folder.get(root, 0) + 1
    if not examples:
        sys.exit("No .ck files found.")
    examples.sort(key=lambda e: (e["root"].lower(), e["path"].lower(), e["root"], e["path"]))

    data = json.dumps({"version": INDEX_VERSION, "count": len(examples), "examples": examples},
                      ensure_ascii=False, separators=(",", ":")).encode("utf-8")
    code_size = sum(len(e["code"].encode("utf-8")) for e in examples)
    without_page = sum(1 for e in examples if not e["page"])

    print(f"{len(examples)} examples ({common.size_text(code_size)} of code):")
    for root, count in sorted(per_folder.items()):
        print(f"  {root} ({count})")
    print(f"{len(examples) - without_page} link to an .html page, {without_page} to the .ck file.")
    print(f"{args.out}: {common.size_text(len(data))}, about {common.size_text(len(gzip.compress(data, 6)))} gzipped.")

    if args.dry_run:
        print("Dry run: nothing written.")
    elif args.out.exists() and args.out.read_bytes() == data:
        print("Already up to date.")
    else:
        args.out.write_bytes(data)
        print("Wrote the index.")


if __name__ == "__main__":
    main()
