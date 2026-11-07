# Example and search tools

Makes webpage for each ChucK example, keeps links to examples pointing at the right file, and builds the two search indexes used by `/search/`. The server only serves files.

## Site layout

| Folder | What it holds |
|---|---|
| `/doe/scripts/` | Scripts, the example page templates, `ignored-examples.txt` |
| `/doc/examples/` | ChucK examples. Pages are made here |
| `/chugl/examples/` | ChuGL examples. Searchable, but their pages come from generate.sh |
| `/search/` | The search page and the two indexes the scripts write |
| `/legacy/` | Left out of everything |

The folders are listed at the top of `site_common.py`. Change them there if they move.

## Everyday use

```
python3 doe/scripts/update_site.py             # rerun everything, in order
python3 doe/scripts/update_site.py --dry-run   # preview; writes nothing
```

Then upload what changed. A script only rewrites a file when its content changed. (In a dry run, later steps don't see the pages the first step would make, so link changes can look incomplete.)

## Ignoring examples

List examples that shouldn't get a page in `ignored-examples.txt`, one per line, `.ck` optional, `#` for comments:

```
test           any test.ck, in any folder
basic/test     only basic/test.ck
serial/        everything in a folder called serial
```

Ignored examples are still searchable. They just link to the `.ck`.

After editing the list, run `update_site.py`. It deletes the example's generated page, points links back at the `.ck`, and updates the index. Remove the line and run it again to bring the page back.

## Which file a link uses

For every example, links and search results use the `.html` page if it exists and the example isn't ignored, otherwise the `.ck`. `relink_examples.py` and `build_example_index.py` both follow this rule, and relinking works in both directions.

## The scripts

All of them accept `--dry-run`.

**`make_example_pages.py [FOLDER ...]`** makes `X.html` next to each `X.ck` (default `doc/examples`).
- `--prune` deletes generated pages whose example is gone or ignored. `update_site.py` always uses it.
- `--force` overwrites pages this script didn't make. Hand-written pages are otherwise never touched; they're listed as "left alone".
- `--template FILE` uses another template. Default: `webchuck-example-template.html` in `/doe/scripts/`.
- The template needs `<title>Title</title>`, an element with `id="title"` containing `Title`, and `<script id="chuck">// chuck code</script>`. An `id="download"` element with `data-href="example.ck"` is optional and gets the file name.

**`relink_examples.py [FOLDER]`** sets every link to an example to its `.html` or `.ck` by the rule above, in HTML pages and in `.md` files. Only the address changes.
- Left alone, and listed: links to other sites, links with a `download` attribute, and `.ck` links to files that aren't in an examples folder.
- In markdown it fixes `[text](address)`, `[ref]: address` lines, `<https://address>` links and raw `<a href>` tags. Code blocks and `` `code spans` `` are never touched, and neither are bare web addresses in the middle of a sentence. Relative links are read from the `.md` file's own folder, which is how zero-md reads them.
- `--host HOST` counts absolute links to another host as your own. `chuck.stanford.edu` is. Links should almost always be relative anyway.

**`build_example_index.py [FOLDER ...]`** writes `search/examples.json` from every `.ck` in `doc/examples` and `chugl/examples`. `--out FILE` writes somewhere else.

**`build_site_index.py [FOLDER]`** writes `search/site.json`: the text of your pages, split at headings. It leaves out the example folders, `legacy`, `doe`, `search`, the templates and `noindex` pages.
- Markdown pages: when a page shows markdown with `<zero-md src="...">`, that file is indexed as part of the page, and results link to the page. A page with no `<zero-md>` tag uses a `.md` with the same name beside it, if there is one. A `.md` that no page shows is left out, and the run lists it. The reading is done by `markdown_pages.py`.
- Section links: results jump to a heading on a markdown page using the ids zero-md 2 gives it (it renders with marked 4). A heading zero-md can't scroll to, one starting with a digit or containing accented letters, links to the top of the page instead. If you move to zero-md 3, check that section links still land.
- `--skip NAME` ignores elements with that tag, class or id (menus, sidebars).
- `--split-level N` splits at headings `h1` to `hN` (default 3). `--exclude DIR` skips a folder. `--ext` changes the file types. `--out FILE` writes somewhere else.

**`update_site.py`** runs the four scripts in this order: pages (with `--prune`), links, example index, site index. It stops at the first failure.

## If something looks wrong

| Problem | Fix |
|---|---|
| Search page says the index is a "different version" | Rebuild the indexes with `update_site.py` |
| An example has no page | It's on the ignore list, or a hand-written page is in the way (listed as "left alone") |
| A link wasn't changed | It's listed under "Left alone" in the run, with the reason |
| A link to a page broke after you deleted its example | Links to a deleted example can't be recognised, so edit them by hand |
| Site search shows menu or footer text | Use `--skip` with that element's class or id |
| A markdown page isn't in site search | It's listed in the run as "aren't shown by any page": no page has a `<zero-md src>` pointing at it, and none has the same name |
