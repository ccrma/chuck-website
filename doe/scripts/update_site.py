#!/usr/bin/env python3
"""
update_site.py - rerun everything, in the right order.

    python3 update_site.py [--dry-run]

  1. make_example_pages.py --prune   example pages (and removes stale ones)
  2. relink_examples.py              links to examples
  3. build_example_index.py          example search index
  4. build_site_index.py             site search index

Stops at the first step that fails. --dry-run is passed to every step, so
nothing is written. (A dry run shows each step as if the earlier ones hadn't
run, so links may look unchanged until the pages really exist.)
"""
import argparse
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent

STEPS = [
    ("Example pages", "make_example_pages.py", ["--prune"]),
    # ("Links to examples", "relink_examples.py", []),
    ("Example search index", "build_example_index.py", []),
    ("Site search index", "build_site_index.py", []),
]


def main():
    ap = argparse.ArgumentParser(description="Rerun every script, in order.")
    ap.add_argument("--dry-run", action="store_true", help="show what would change; write nothing")
    args = ap.parse_args()

    for title, script, extra in STEPS:
        print(f"\n== {title} ==")
        command = [sys.executable, str(HERE / script)] + extra + (["--dry-run"] if args.dry_run else [])
        if subprocess.run(command).returncode != 0:
            sys.exit(f"\n{script} failed, so the later steps were not run.")


if __name__ == "__main__":
    main()
