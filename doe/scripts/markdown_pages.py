"""
Turns the markdown that pages show with <zero-md> into searchable sections.

Used by build_site_index.py, which does the same for HTML pages. zero-md 2
renders markdown with marked 4, so heading ids here follow marked 4's rules.
That's what lets a search result jump straight to a section.
"""
import re
from html import unescape

ATX_HEADING = re.compile(r"^ {0,3}(#{1,6})[ \t]+(.+?)(?:[ \t]+#+)?[ \t]*$")   # ## Heading
SETEXT_UNDERLINE = re.compile(r"^ {0,3}(=+|-+)[ \t]*$")                        # Heading, then ==== or ----
LIST_ITEM = re.compile(r"^\s*(?:[-*+>]|\d+[.)])[ \t]")
RULE = re.compile(r"^ {0,3}([-*_])(?:[ \t]*\1){2,}[ \t]*$")
TABLE_DIVIDER = re.compile(r"^\s*\|?\s*:?-{2,}:?\s*(?:\|\s*:?-{2,}:?\s*)*\|?\s*$")
LINK_DEFINITION = re.compile(r"^ {0,3}\[[^\]]+\]:[ \t]*\S+")
CODE_SPAN = re.compile(r"(`+)(.+?)\1", re.S)

# What marked removes from a heading's text when it makes the heading's id
ID_PUNCTUATION = re.compile(r"[\u2000-\u206F\u2E00-\u2E7F\\'!\"#$%&()*+,./:;<=>?@\[\]^`{|}~]")
# zero-md scrolls to a #hash with querySelector, which only works for plain ids like these
SCROLLABLE_ID = re.compile(r"[A-Za-z_][A-Za-z0-9_-]*")


def squash(text):
    return re.sub(r"\s+", " ", text).strip()


def heading_id(text, seen):
    """The id marked gives a heading: lowercase, punctuation dropped, whitespace
    turned into hyphens, and -1, -2 added to repeats."""
    slug = re.sub(r"\s", "-", ID_PUNCTUATION.sub("", text.lower().strip()))
    if slug in seen:
        original = slug
        while True:
            seen[original] += 1
            slug = f"{original}-{seen[original]}"
            if slug not in seen:
                break
    seen[slug] = 0
    return slug


def plain_inline(text):
    """Markdown inside a line -> plain text. Code is kept exactly as written."""
    codes = []

    def stash(match):
        codes.append(match.group(2).strip())
        return f"\x00{len(codes) - 1}\x00"

    text = CODE_SPAN.sub(stash, text)
    text = re.sub(r"!\[([^\]]*)\]\([^)]*\)", r"\1", text)               # images -> their alt text
    text = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", text)                # links -> their text
    text = re.sub(r"\[([^\]]+)\]\[[^\]]*\]", r"\1", text)               # reference links -> their text
    text = re.sub(r"<(https?://[^>\s]+)>", r"\1", text)                 # <http://autolinks>
    text = re.sub(r"</?(?:br|p|div|li|ul|ol|tr|td|th|table|hr|pre|blockquote|h[1-6])\b[^<>]*>", " ", text)  # tags that separate words
    text = re.sub(r"</?[A-Za-z][^<>]*>", "", text)                      # other HTML tags (but not <<< or a < b)
    text = re.sub(r"(\*\*|__)(.+?)\1", r"\2", text)                     # **bold**
    text = re.sub(r"(?<![\w*])\*(?=\S)(.+?)(?<=\S)\*(?![\w*])", r"\1", text)   # *italic*
    text = re.sub(r"(?<![\w_])_(?=\S)(.+?)(?<=\S)_(?![\w_])", r"\1", text)    # _italic_, not snake_case
    text = re.sub(r"~~(.+?)~~", r"\1", text)
    text = unescape(text)
    return re.sub(r"\x00(\d+)\x00", lambda m: codes[int(m.group(1))], text)


def plain_line(line):
    """One line of markdown prose -> plain text (blank for rules, table dividers and link definitions)."""
    if RULE.match(line) or LINK_DEFINITION.match(line):
        return ""
    line = re.sub(r"^ {0,3}(?:>[ \t]?)+", "", line)                                   # quote marker
    line = re.sub(r"^\s*(?:[-*+]|\d+[.)])[ \t]+(?:\[[ xX]\][ \t]+)?", "", line)       # list or task marker
    if TABLE_DIVIDER.match(line):
        return ""
    if line.lstrip().startswith("|"):
        line = line.replace("|", " ")                                                 # table row
    return plain_inline(line)


def mask_code(text):
    """Hides code blocks and `code spans` behind placeholders, so that edits to the
    rest of the text can't touch code. Returns the masked text and what was hidden;
    give both to unmask() when done. Line endings are kept exactly."""
    saved = []

    def hide(piece):
        saved.append(piece)
        return f"\x00{len(saved) - 1}\x00"

    kept, block, fence = [], [], None
    for line in text.splitlines(keepends=True):
        bare = line.rstrip("\r\n")
        if fence:
            block.append(line)
            stripped = bare.strip()
            if stripped and set(stripped) == {fence[0]} and len(stripped) >= len(fence):
                kept.append(hide("".join(block)))
                block, fence = [], None
            continue
        opening = re.match(r"^ {0,3}(`{3,})[^`]*$", bare) or re.match(r"^ {0,3}(~{3,}).*$", bare)
        if opening:
            fence = opening.group(1)
            block = [line]
        else:
            kept.append(line)
    if block:                                            # a code block left open at the end of the file
        kept.append(hide("".join(block)))
    masked = CODE_SPAN.sub(lambda m: hide(m.group(0)), "".join(kept))
    return masked, saved


def unmask(text, saved):
    """Puts back what mask_code() hid."""
    return re.sub(r"\x00(\d+)\x00", lambda m: saved[int(m.group(1))], text)


def parse_markdown(text, split_level=3, page_top=True):
    """Splits markdown into sections: a list of {id, heading, text}.

    A new section starts at each heading from # up to the split level. Smaller
    headings stay inside their section as text. Code blocks are kept as written,
    and a # inside one is not a heading.

    page_top says whether this markdown starts the page. If so, its first # heading
    is the page's own title and needs no anchor."""
    text = re.sub(r"<!--.*?-->", "", text.replace("\r\n", "\n").replace("\r", "\n"), flags=re.S)
    lines = text.split("\n")
    sections, seen_ids = [], {}
    current = {"id": "", "heading": "", "parts": []}

    def finish_section():
        nonlocal current
        body = squash(" ".join(current["parts"]))
        if current["heading"] or body:
            sections.append({"id": current["id"], "heading": current["heading"], "text": body})
        current = {"id": "", "heading": "", "parts": []}

    def add_heading(level, raw):
        heading = squash(plain_inline(raw))
        if not heading:
            return
        anchor = heading_id(heading, seen_ids)           # every heading counts, as in the renderer
        if level > split_level:
            current["parts"].append(heading)
            return
        at_top = page_top and level == 1 and not sections and not current["heading"] and not squash(" ".join(current["parts"]))
        finish_section()
        current["heading"] = heading
        usable = SCROLLABLE_ID.fullmatch(anchor) and not at_top
        current["id"] = anchor if usable else ""         # no anchor: the result opens the page at the top

    fence = None
    i = 0
    while i < len(lines):
        line = lines[i]
        if fence:                                        # inside a code block
            stripped = line.strip()
            if stripped and set(stripped) == {fence[0]} and len(stripped) >= len(fence):
                fence = None
            else:
                current["parts"].append(line)
            i += 1
            continue
        opening = re.match(r"^ {0,3}(`{3,})[^`]*$", line) or re.match(r"^ {0,3}(~{3,}).*$", line)
        if opening:
            fence = opening.group(1)
            i += 1
            continue
        atx = ATX_HEADING.match(line)
        if atx:
            add_heading(len(atx.group(1)), atx.group(2))
            i += 1
            continue
        if (i + 1 < len(lines) and line.strip() and not LIST_ITEM.match(line)
                and not re.fullmatch(r"[-=*_ \t]+", line.strip()) and "|" not in line):
            underline = SETEXT_UNDERLINE.match(lines[i + 1])
            if underline:                                # Heading, then ==== or ----
                add_heading(1 if underline.group(1)[0] == "=" else 2, line.strip())
                i += 2
                continue
        current["parts"].append(plain_line(line))
        i += 1
    finish_section()
    return sections
