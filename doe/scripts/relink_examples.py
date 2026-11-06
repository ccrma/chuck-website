#!/usr/bin/env python3
"""
relink_examples.py - point links to examples at the right file.

    python3 relink_examples.py [FOLDER] [--host HOST] [--dry-run]

Looks at every link in your HTML pages and markdown files that points at an
example (X.ck or X.html) and sets it to X.html if that page exists and the
example isn't on the ignore list, otherwise to X.ck. It works in both
directions, so you can run it any time: after new pages are made, after an
example is put on the ignore list, or after a page is deleted.

Only the link's address changes. The rest of each file is kept byte for byte.

In markdown it fixes [text](address), [text][ref] definitions (the
"[ref]: address" lines), <https://...> links, and raw <a href> tags. Code
blocks and `code spans` are never touched, and neither are bare web addresses
in the middle of a sentence.
"""
import argparse
import os
import re
import sys
from pathlib import Path
from urllib.parse import quote

import markdown_pages
import site_common as common

# ---- Finding links -----------------------------------------------------------
# HTML: <a ... href="address" ...>
ANCHOR = re.compile(r"<a\b[^>]*>", re.I | re.S)
HREF = re.compile(r"""(?<![\w-])href\s*=\s*(?:"([^"]*)"|'([^']*)'|([^\s"'>]+))""", re.I)
DOWNLOAD = re.compile(r"(?<![\w-])download(?=[\s=/>])", re.I)
QUOTED = re.compile(r"\"[^\"]*\"|'[^']*'")

# Markdown, each with the address in a group called "url"
MARKDOWN_LINKS = [
    re.compile(r"\]\(\s*<?(?P<url>[^)\s<>]+)>?(?:\s+(?:\"[^\"]*\"|'[^']*'))?\s*\)"),   # [text](address "title")
    re.compile(r"^ {0,3}\[[^\]]+\]:[ \t]*<?(?P<url>[^\s>]+)", re.M),                  # [ref]: address
    re.compile(r"<(?P<url>https?://[^>\s]+)>"),                                        # <https://address>
]

# An address ending in .ck or .html, with an optional ?query or #fragment after it
EXAMPLE_LINK = re.compile(r"^(?P<path>[^?#]*)\.(?P<ext>ck|html)(?P<tail>[?#].*)?$", re.I | re.S)


# ---- Deciding what a link should be ---------------------------------------------
def decide(url, source_file, ignored, hosts):
    """What should happen to a link found in source_file?

    Returns (new_address, note). new_address is None when the link stays as it is.
    note is set when a .ck link was left alone for a reason worth telling you."""
    link = EXAMPLE_LINK.match(url.strip())
    if not link:
        return None, None
    is_ck_link = link.group("ext").lower() == "ck"

    target = common.local_file(source_file, url.strip(), hosts)
    if target is None:
        return None, ("other_site" if is_ck_link else None)         # another website
    ck = target.with_suffix(".ck")
    if not (ck.is_file() and common.is_example(ck)):
        return None, ("not_example" if is_ck_link else None)        # an ordinary page

    wanted = ".html" if common.has_page(ck, ignored) else ".ck"
    relative_path = os.path.relpath(ck.with_suffix(wanted), Path(source_file).parent)
    relative_path = Path(relative_path).as_posix()
    new_url = quote(relative_path, safe="/:@-._~") + (link.group("tail") or "")
    if new_url == url.strip():
        return None, None                                           # already right
    return new_url, None


# ---- Fixing a file -----------------------------------------------------------
def relink_html(text, page, ignored, hosts, notes):
    where = common.site_path(page)

    def fix(match):
        tag = match.group(0)
        href = HREF.search(tag)
        if not href:
            return tag
        group = next(i for i in (1, 2, 3) if href.group(i) is not None)
        url = href.group(group).strip()
        new_url, note = decide(url, page, ignored, hosts)
        if note:
            notes[note].append((where, url))
        if new_url is None:
            return tag
        if DOWNLOAD.search(QUOTED.sub('""', tag)):
            notes["download"].append((where, url))
            return tag
        notes["changed"].append((where, url, new_url))
        start, end = href.span(group)
        return tag[:start] + new_url + tag[end:]

    return ANCHOR.sub(fix, text)


def relink_markdown(text, md_file, ignored, hosts, notes):
    where = common.site_path(md_file)
    text, hidden = markdown_pages.mask_code(text)      # links inside code stay as written

    def fix(match):
        url = match.group("url")
        new_url, note = decide(url, md_file, ignored, hosts)
        if note:
            notes[note].append((where, url))
        if new_url is None:
            return match.group(0)
        notes["changed"].append((where, url, new_url))
        start, end = match.span("url")
        offset = match.start()
        return match.group(0)[:start - offset] + new_url + match.group(0)[end - offset:]

    for pattern in MARKDOWN_LINKS:
        text = pattern.sub(fix, text)
    text = relink_html(text, md_file, ignored, hosts, notes)    # raw <a href> tags inside markdown
    return markdown_pages.unmask(text, hidden)


def main():
    ap = argparse.ArgumentParser(description="Point links to examples at the right file.")
    ap.add_argument("folder", nargs="?", type=Path, default=common.SITE_ROOT,
                    help="folder to fix (default: the whole site)")
    ap.add_argument("--host", action="append", default=[], metavar="HOST",
                    help=f"also treat absolute links to this host as part of the site (already: "
                         f"{', '.join(common.SITE_HOSTS)}). Repeatable")
    ap.add_argument("--dry-run", action="store_true", help="list every change; write nothing")
    args = ap.parse_args()

    if not args.folder.is_dir():
        sys.exit(f"Not a folder: {args.folder}")
    common.require_inside_site(args.folder)
    hosts = {h.lower() for h in common.SITE_HOSTS + args.host}
    ignored = common.load_ignore_list()
    notes = {"changed": [], "download": [], "other_site": [], "not_example": []}

    files = common.find_files(args.folder.resolve(), {".html", ".htm", ".md"}, skip=common.NON_PAGE_FOLDERS)
    for path in files:
        is_markdown = path.suffix.lower() == ".md"
        if not is_markdown and common.is_generated(path):
            continue                                   # made by make_example_pages.py: no links to fix
        raw = path.read_bytes()
        try:
            text, encoding = raw.decode("utf-8"), "utf-8"
        except UnicodeDecodeError:
            text, encoding = raw.decode("latin-1"), "latin-1"
        relink = relink_markdown if is_markdown else relink_html
        fixed = relink(text, path, ignored, hosts, notes)
        if fixed != text and not args.dry_run:
            path.write_bytes(fixed.encode(encoding))

    changed = notes["changed"]
    changed_files = sorted({where for where, *_ in changed})
    verb = "would be" if args.dry_run else "were"
    print(f"{len(changed)} links in {len(changed_files)} files {verb} changed.")
    if args.dry_run:
        for where, old, new in changed:
            print(f"  {where}: {old} -> {new}")
    else:
        for where in changed_files:
            print(f"  {where} ({sum(1 for w, *_ in changed if w == where)})")

    left = (("download", "Left alone, links with a download attribute"),
            ("other_site", "Left alone, .ck links to other websites (use --host if any are yours)"),
            ("not_example", "Left alone, .ck links to files that aren't examples, or are missing"))
    for key, label in left:
        if notes[key]:
            print(f"\n{label}:")
            for where, url in notes[key]:
                print(f"  {where}: {url}")


if __name__ == "__main__":
    main()
