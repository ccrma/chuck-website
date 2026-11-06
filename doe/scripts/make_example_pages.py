#!/usr/bin/env python3
"""
make_example_pages.py - make a web page for every example.

    python3 make_example_pages.py [FOLDER ...] [--dry-run] [--prune] [--force]

For each X.ck it writes X.html beside it, built from the template. With no
folder it uses the default (doc/examples). Examples on the ignore list
(ignored-examples.txt) get no page.

Safe to re-run: unchanged pages aren't rewritten, and a page that wasn't made
by this script is never overwritten unless you pass --force.
"""
import argparse
import html
import re
import sys
from pathlib import Path
from urllib.parse import quote
import os

import site_common as common

MARKER = f"<!-- {common.GENERATED_MARKER} from the matching .ck file. Edits will be overwritten. -->"

# The places the template is filled in. Elements are found by id, so the
# template's styling, tags and attribute order can change freely.
TITLE_TAG = re.compile(r"(<title\b[^>]*>)Title(</title>)", re.I)
TITLE_ELEMENT = re.compile(r"""(<(\w+)\b[^>]*(?<![\w-])id=["']title["'][^>]*>)Title(</\2>)""", re.I)
CODE_SCRIPT = re.compile(r"""(<script\b[^>]*(?<![\w-])id=["']chuck["'][^>]*>)// chuck code(</script>)""", re.I)
# Optional: an id="download" element with href="example.ck" (a link) or data-href="example.ck" (a button)
DOWNLOAD_TAG = re.compile(r"""<\w+\b[^>]*(?<![\w-])id=["']download["'][^>]*>""", re.I)
DOWNLOAD_HREF = re.compile(r"""((?<![\w-])(?:data-)?href=["'])example\.ck(["'])""", re.I)
DOCTYPE = re.compile(r"<!doctype html>\n", re.I)


# ---- Building a page ---------------------------------------------------------
def load_template(path):
    """Read the template and check it has the three places we fill in."""
    template = path.read_text(encoding="utf-8")
    required = (("<title>Title</title>", TITLE_TAG),
                ('an element with id="title" containing the text Title', TITLE_ELEMENT),
                ('a <script id="chuck"> containing // chuck code', CODE_SCRIPT))
    for what, pattern in required:
        found = len(pattern.findall(template))
        if found != 1:
            sys.exit(f"The template {path} needs exactly one {what} (found {found}).")
    if not any(DOWNLOAD_HREF.search(tag[0]) for tag in DOWNLOAD_TAG.finditer(template)):
        print('note: the template has no id="download" element with href="example.ck" '
              'or data-href="example.ck", so pages get no download link.')
    if "{{ROOT}}" not in template:
        sys.exit(f"The template {path} needs a {{{{ROOT}}}} placeholder.")
    # Mark every page as generated, right after the doctype
    if DOCTYPE.search(template):
        return DOCTYPE.sub(lambda m: m[0] + MARKER + "\n", template, count=1)
    return MARKER + "\n" + template


def escape_code(code):
    """Make code safe to put inside the template's <script>.

    The template turns that text into a JavaScript template literal, so
    backslashes, backticks and ${ would be misread (a ChucK "\\n" would become a
    real line break). </script and <!-- would confuse the HTML parser."""
    code = code.replace("\\", "\\\\").replace("`", "\\`").replace("${", "\\${")
    code = re.sub(r"</(script)", r"<\\/\1", code, flags=re.I)
    return code.replace("<!--", "<\\!--")


def make_page(template, code, ck_name, page_to_root):
    title = html.escape(Path(ck_name).stem, quote=False)
    page = template.replace("{{ROOT}}", page_to_root)
    page = TITLE_TAG.sub(lambda m: m[1] + title + m[2], page)
    page = TITLE_ELEMENT.sub(lambda m: m[1] + title + m[3], page)
    download = quote(ck_name)
    page = DOWNLOAD_TAG.sub(
        lambda tag: DOWNLOAD_HREF.sub(lambda h: h[1] + download + h[2], tag[0]), page)
    # The code goes in last, starting right after the tag and ending right before
    # the closing tag, so the editor shows it exactly as it is in the .ck
    return CODE_SCRIPT.sub(lambda m: m[1] + escape_code(code.rstrip()) + m[2], page)


# ---- One folder --------------------------------------------------------------
def make_pages_in(folder, template, ignored, args):
    files = common.find_files(folder, {".ck", ".html"}, skip=common.LEFT_OUT_FOLDERS)
    ck_files = [f for f in files if f.suffix.lower() == ".ck"]
    html_files = [f for f in files if f.suffix.lower() == ".html"]

    new, changed, left_alone, unchanged, ignored_count = [], [], [], 0, 0
    wanted_pages = set()
    page_to_root = Path(os.path.relpath(common.SITE_ROOT, folder)).as_posix()
    for ck in ck_files:
        if ignored.matches(ck):
            ignored_count += 1
            continue
        page_file = ck.with_suffix(".html")
        wanted_pages.add(page_file)
        page = make_page(template, common.read_text(ck), ck.name, page_to_root)
        if page_file.exists():
            if not args.force and not common.is_generated(page_file):
                left_alone.append(page_file)           # hand-written: don't touch
                continue
            if page_file.read_text(encoding="utf-8", errors="replace") == page:
                unchanged += 1
                continue
            changed.append(page_file)
        else:
            new.append(page_file)
        if not args.dry_run:
            page_file.write_text(page, encoding="utf-8", newline="\n")

    # Generated pages whose example is gone or has since been put on the ignore list
    stale = [p for p in html_files if p not in wanted_pages and common.is_generated(p)]
    if args.prune and not args.dry_run:
        for page_file in stale:
            page_file.unlink()

    def names(paths):
        return "\n".join(f"    {p.relative_to(folder)}" for p in paths)

    verb = "would be" if args.dry_run else "were"
    print(f"{common.site_path(folder)}: {len(ck_files)} examples")
    print(f"  {len(new)} new and {len(changed)} updated pages {verb} written, "
          f"{unchanged} unchanged, {ignored_count} ignored")
    if args.dry_run and (new or changed):
        print(names(new + changed))
    if left_alone:
        print(f"  Left alone, not made by this script (--force overwrites):\n{names(left_alone)}")
    if stale:
        what = "Deleted" if args.prune and not args.dry_run else "Stale"
        hint = "" if args.prune else " (--prune deletes them)"
        print(f"  {what} pages with no example, or whose example is ignored{hint}:\n{names(stale)}")


def main():
    ap = argparse.ArgumentParser(description="Make a web page for every example.")
    ap.add_argument("folders", nargs="*", type=Path,
                    help=f"folders to make pages in (default: {', '.join(common.PAGE_FOLDERS)})")
    ap.add_argument("--template", type=Path, default=common.TEMPLATE_FILE,
                    help="page template (default: %(default)s)")
    ap.add_argument("--force", action="store_true",
                    help="overwrite existing pages even if this script didn't make them")
    ap.add_argument("--prune", action="store_true",
                    help="delete generated pages whose example is gone or ignored")
    ap.add_argument("--dry-run", action="store_true", help="show what would change; write nothing")
    args = ap.parse_args()

    folders = args.folders or [common.folder(name) for name in common.PAGE_FOLDERS]
    for folder in folders:
        if not folder.is_dir():
            sys.exit(f"Not a folder: {folder}")
        common.require_inside_site(folder)
    if not args.template.is_file():
        sys.exit(f"Can't find the template {args.template}. It belongs in the same folder as this script.")

    template = load_template(args.template)
    ignored = common.load_ignore_list()
    for folder in folders:
        make_pages_in(folder.resolve(), template, ignored, args)


if __name__ == "__main__":
    main()
