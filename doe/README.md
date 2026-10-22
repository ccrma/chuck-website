# Examples and search tools

Small pieces that turn a folder of `.ck` files into browsable web examples, and make both the examples and the rest of the site searchable. Everything runs on your own computer; the server only ever serves static files.

| File | What it is |
|---|---|
| `make_example_pages.py` | Makes `X.html` (editor, Play button, console, download) next to every `X.ck` |
| `relink_examples.py` | Changes `<a href="...ck">` links in your pages to point at the new `.html` pages |
| `build_search_index.py` | Builds `examples.json`: the code of every example in every folder named `examples`, for searching code |
| `build_site_index.py` | Builds `site.json`: the text of your pages, split by heading, for searching the site |
| `web-example-template.html` | The page template `make_example_pages.py` fills in |
| `random-example.html` | A "Random example" button for your main page, with a demo page around it |
| `search/index.html` | The search page, served at `/search/`, with a switch between example code and site pages (runs entirely in the visitor's browser) |

Requires Python 3.10 or newer, with no extra packages. Every script has `--help`, and every script that changes files has `--dry-run`.

## How it fits together

```
 X.ck  ──make_example_pages.py──▶  X.html            (one page per example)
   │
   └─────build_search_index.py──▶  search/examples.json  (all the code, in one file)

 your pages ──build_site_index.py──▶  search/site.json      (all the page text, split by heading)

 your pages ──relink_examples.py──▶ links now point at X.html instead of X.ck

 visitor opens /search/ ─ downloads the index for the mode they pick ─ searches it in the browser
```

The `.ck` files are the single source of truth. The HTML pages and the example index are generated from them, so never edit those by hand; change the `.ck` (or the template) and re-run.

## Setting it up

1. **Keep the tools off the server.** Put the scripts and template in your repo or on your computer; `build_search_index.py` and `build_site_index.py` expect to sit one folder below the site root (for you, `SITE/doc/`) so that `../search/` is the search folder. Below, `SITE` is the root of your website and `EX` is one of your examples folders (for you, `SITE/doc/examples`, and the second one).
2. **Preview the pages:** `python3 make_example_pages.py EX --dry-run`
3. **Make the pages.** This script takes one examples folder at a time, so run it once for each: `python3 make_example_pages.py EX` for the first, then again for the second. It looks for `web-example-template.html` in the folder it's given, then next to the script, so for the folders without a copy, keep one next to the script or pass `--template`.
4. **Fix links to examples** (your examples index, tutorials, and so on):
   `python3 relink_examples.py SITE --dry-run`, read the "left as .ck" lists, then run it again without `--dry-run`. `SITE` is the folder holding the pages to fix. Run step 3 first so the targets exist.
5. **Build the examples index:** `python3 build_search_index.py`. Run it with no folder: it looks through the whole site for every folder named `examples` and indexes the `.ck` files inside, wherever they are. With the script in `SITE/doc/`, it writes `SITE/search/examples.json` by itself (the folder must already exist). The index never goes into an examples folder, because those ship with the software. The run lists each examples folder it found and how many examples are in it, which is the quickest way to check it found both.
6. **Build the site-content index:** `python3 build_site_index.py`. With the script in `SITE/doc/`, it reads every page under `SITE`, and writes `SITE/search/site.json`. Run it with `--dry-run` first and read the "Left out" and "Largest pages" lines. See [build_site_index.py](#build_site_indexpy).
7. **Copy `search/index.html` to `SITE/search/index.html`.** The defaults assume the examples are at `/doc/examples/` and the indexes at `/search/examples.json` and `/search/site.json`. If yours differ, see [Search page settings](#search-page-settings).
8. **Test locally.** Browsers block `fetch` from `file://`, so serve the whole site: `cd SITE && python3 -m http.server 8000`, then open `http://localhost:8000/search/`. Serve the site root, not a subfolder, because the page's links are paths from the root.
9. **Upload** the `.ck` files, the generated `.html` pages, `search/index.html`, `search/examples.json` and `search/site.json`.
10. **Link to it.** Add a link to `/search/` from your examples index, or drop in a search box that sends people straight to results:
   ```html
   <form action="/search/" method="get">
     <input type="search" name="q" placeholder="Search the examples">
     <button>Search</button>
   </form>
   ```

   To make the box search site pages instead of example code, add `<input type="hidden" name="mode" value="site">` inside the form.

**Whenever content changes**, re-run what applies, then upload what changed:

```
python3 make_example_pages.py EX --prune   # examples changed (once per examples folder)
python3 build_search_index.py              # examples changed
python3 build_site_index.py                # any page changed
```

All of these leave unchanged files untouched, so only real changes show up in your upload or commit.

---

## make_example_pages.py

```
python3 make_example_pages.py FOLDER [options]
```

Finds every `.ck` under `FOLDER` and writes the matching `.html` in the same place.

| Option | Meaning |
|---|---|
| `FOLDER` | Folder to search recursively |
| `--template FILE` | Template to use. Default: `web-example-template.html` in `FOLDER`, then next to the script |
| `--exclude DIR` | Skip a folder, by name (`serial`) or path (`osc/multicast`). Repeatable. Matches anywhere in the path |
| `--force` | Overwrite existing `.html` files even if this script didn't make them |
| `--prune` | Delete generated pages whose `.ck` no longer exists |
| `--dry-run` | Show what would happen; write nothing |

How it works:

- **Title:** the filename without `.ck`. It's used in the `<title>`, the heading, and as the filename when sending to the WebChucK IDE.
- **Code placement:** the code goes right after the opening `<script id="chuck">` tag and the closing tag follows the last line, so nothing is indented. Trailing blank lines are dropped.
- **Escaping:** the template wraps the code in a JavaScript template literal when the page loads, so the script escapes backslashes, backticks, `${`, `</script` and `<!--`. A ChucK `"\n"` therefore arrives unchanged.
- **Download button:** `data-href="example.ck"` (or `href="example.ck"` on a link) is replaced with the example's own file name.
- **Safe to re-run:** each generated page starts with a "Generated by make_example_pages.py" comment. Pages without it (hand-written ones) are never overwritten unless you pass `--force`, and are listed instead. Pages that haven't changed aren't rewritten.
- **Exit on a broken template:** if the template is missing a placeholder, the script stops and says which, rather than producing hundreds of broken pages.

### What the template must contain

Elements are found by `id`, so you can restyle freely (tag names, classes, attribute order, quotes). Keep these:

| Needed | Why |
|---|---|
| `<title>Title</title>` | Filled with the example title |
| An element with `id="title"` whose text is `Title` | Filled with the title; the page JavaScript also reads it |
| `<script id="chuck" ...>// chuck code</script>` | Filled with the code |
| `id="download"` with `data-href="example.ck"` or `href="example.ck"` | Optional. Filled with the file name. A note is printed if absent |
| `action`, `openInIDE`, `editor`, `chuck-console` | Used by the page's own JavaScript, not by the script |

The copy of `web-example-template.html` provided with these tools is a starting point. If you've kept editing your own, yours wins.

---

## relink_examples.py

```
python3 relink_examples.py FOLDER [options]
```

Scans `.html`/`.htm` files under `FOLDER`. In each `<a>` tag whose `href` ends in `.ck`, it changes `.ck` to `.html`. Handles `/example/basic/demo1.ck`, `./demo.ck`, `demo.ck`, and endings like `demo.ck#top`.

| Option | Meaning |
|---|---|
| `FOLDER` | Site folder to scan recursively |
| `--exclude DIR` | Don't edit pages inside this folder. Repeatable |
| `--keep-ck DIR` | Leave links that *point into* this folder as `.ck` (for folders with no web version). Repeatable |
| `--host HOST` | Treat absolute links to this host as local, e.g. `chuck.stanford.edu`. Repeatable |
| `--ext EXT ...` | File types to scan. Default: `.html .htm` |
| `--dry-run` | List every change; write nothing |

How it works:

- **Only the `href` value changes.** The rest of each file is preserved byte for byte, including line endings and encoding.
- **Left alone, and reported:** links to other websites, links with a `download` attribute, and links into `--keep-ck` folders. Relative links are resolved against the page's location, so `../serial/s.ck` is caught by `--keep-ck serial`.
- **Re-running is harmless.** Once links are converted, there is nothing left to change.
- **Link text isn't touched.** A link that reads `foo.ck` still reads `foo.ck`, but now opens the web page.

`--exclude` and `--keep-ck` apply to different things. If some folders have no web version, skip them in `make_example_pages.py --exclude serial` and use `relink_examples.py --keep-ck serial`.

---

## build_search_index.py

```
python3 build_search_index.py [FOLDER] [options]
```

Run it at the root of the site. It looks for folders named `examples` at any depth and reads every `.ck` file inside them, then writes the index (`examples.json`). `.ck` files outside an examples folder are ignored.

| Option | Meaning |
|---|---|
| `FOLDER` | Where to look for examples folders. Default: the whole site. You can also point it at one examples folder (or a folder inside one), which still counts as an examples folder |
| `--site-root DIR` | The folder your server serves as `/`. Default: the folder above the script's folder (for a script in `SITE/doc/`, that's `SITE`). Needed only if your layout differs |
| `--folder-name NAME` | What the folders that hold examples are called. Default: `examples`. Repeatable, for example `--folder-name examples --folder-name demos` |
| `--out FILE` | Where to write the index. Default: `../search/examples.json`, found relative to the script, not to where you run it from, so a script in `SITE/doc/` writes `SITE/search/examples.json`. The folder must already exist. If the script lives somewhere else, pass this |
| `--exclude DIR` | Skip a folder, by name or path, counted from `FOLDER`. Repeatable |
| `--dry-run` | Report what would be indexed and the sizes; write nothing |

How it works:

- **One entry per example:** the examples folder it's in (`doc/examples`), its path inside that folder (`basic/sinosc.ck`), the code, and whether an `.html` page exists beside it. Addresses are worked out from the site root, so examples in different places all link correctly. If there's no page, search results link to the `.ck` file itself, so there's no need to exclude folders that have no web version.
- **Which folders count:** the outermost folder with a matching name, so `doc/examples/basic/examples/` is indexed as part of `doc/examples`, not twice. Hidden files and folders are skipped.
- **Deterministic output:** no timestamps, entries sorted by folder and path, so an unchanged index isn't rewritten.
- **Size:** about the size of your code (roughly 0.8 MB for 637 examples, a fraction of that gzipped). Visitors download it once per visit.
- **No code is lost to formatting:** line endings are normalised to `\n` and trailing whitespace at the end of each file is trimmed. Everything else is kept as is.

---

## build_site_index.py

```
python3 build_site_index.py [FOLDER] [options]
```

Reads the HTML pages (and markdown files) under `FOLDER`, strips menus, headers and footers, splits each page into sections at its headings, and writes `site.json`.

| Option | Meaning |
|---|---|
| `FOLDER` | Folder to scan recursively. Default: the whole site. Addresses always count from the site root, so scanning only `SITE/doc` still gives `/doc/...` addresses |
| `--site-root DIR` | The folder your server serves as `/`. Default: the folder above the script's folder (for a script in `SITE/doc/`, that's `SITE`). Needed only if your layout differs |
| `--out FILE` | Where to write the index. Default: `../search/site.json`, found relative to the script, not to where you run it from. The folder must already exist |
| `--exclude DIR` | Skip a folder, by name or path (`release`, `old/docs`), counted from `FOLDER`. Repeatable |
| `--skip NAME` | Also ignore elements with this tag name, class or id, for example `outlineDiv`. Repeatable |
| `--split-level N` | Start a new section at headings `h1` to `hN`. Default: 3 |
| `--ext EXT ...` | Page extensions to read. Default: `.html .htm .md`. Leave out `.md` to ignore markdown |
| `--md-raw` | Also index `.md` files that have no matching `.html` page, linking to the `.md` file itself. Default: leave them out |
| `--no-md-anchors` | Link markdown results to the top of the page instead of `#heading-ids`. Use this if your page doesn't create heading ids |
| `--dry-run` | Report what would be indexed; write nothing |

How it works:

- **What's ignored:** `<head>`, scripts, styles, `<nav>`, `<header>`, `<footer>`, `<aside>`, buttons, and any element whose class or id contains `header`, `footer`, `nav`, `navbar`, `menu`, `sidebar` or `breadcrumb` (or whose role is navigation, banner or contentinfo). If boilerplate still shows up in results, name it with `--skip`.
- **Sections:** each heading from `h1` to `h3` starts a section, holding the text up to the next one. Smaller headings stay inside their section. Long reference pages therefore turn into many small, linkable results. Use `--split-level 4` for finer sections or `2` for coarser ones.
- **Section links:** a section links straight to its heading when the heading has an `id`, contains `<a id>` or `<a name>`, or is preceded by an empty `<a name>`. Otherwise the result links to the top of the page. The script reports how many sections lack an anchor; adding `id="..."` to those headings fixes it.
- **Left out automatically:** pages made by `make_example_pages.py` (their code is in the examples index), the example page template, pages with `<meta name="robots" content="noindex">`, pages with no readable text, and everything in the folder the index is written to (the search page itself). The run reports how many of each.
- **Addresses:** `index.html` pages get their folder address (`/doc/language/`), and file names are URL-encoded.
- **Deterministic:** no timestamps, so an unchanged index isn't rewritten. The run prints the size, the gzipped size, and the five largest pages.
- **Markdown:** if `foo.md` has a `foo.html` beside it (the HTML page loads and shows the markdown), the text is indexed from the `.md` and results link to `foo.html`. The `.html` page itself is skipped, since it only displays the markdown, and if it's marked `noindex` the markdown is skipped too. The title comes from the front matter `title:`, else the first `# Heading`, else the file name. Sections split at `#` headings (not inside code blocks), and links, emphasis, tables, lists and quotes are reduced to plain text. Code is kept as written, so `=>` and `<<<` stay searchable.
- **Markdown section links:** headings get GitHub-style ids (`## Getting started` becomes `#getting-started`, repeats become `-1`, `-2`). They only jump to the section if your page creates the same ids, and also scrolls to `location.hash` after it has displayed the markdown, since the heading doesn't exist until then. If it doesn't, results still open the right page, at the top. `--no-md-anchors` removes the `#...` from the links.
- **Markdown with no page:** a `.md` with no `.html` beside it has nothing to link to (a repo `README.md`, for example), so it's left out and listed in the run. `--md-raw` indexes those too, linking to the raw `.md`.
- **Not indexed:** text inside images or PDFs.

---

## Search page

### What visitors can do

Two radio buttons choose what to search: **Example code** or **Site pages**. Both use the same box, options and shareable addresses.

**Example code** is a literal search:

- Type to search as you go; results update after a short pause.
- `=>`, `GGen`, `<<<` and other punctuation work, because the text is matched as typed, not split into words.
- **Spaces match any whitespace**, including line breaks and different indentation. Pasting a snippet matches the code even if it's laid out differently. Pasted line breaks become spaces.
- **Match case** and **Regular expression** are off by default. Regular expressions run across the whole file with `^` and `$` matching at line boundaries.
- Results are grouped by example: the folder, the file name (a link to the example page), an "Open .ck file" link, then the matching lines with line numbers, one line of context, and highlighted matches. The first six matching lines show with a button for the rest, and the first 40 examples with a button for more.
- An example whose *name* matches is listed too, marked "name matches", and sorted first.

**Site pages** is a word search:

- Every word you type has to appear in the same section, in any order. Put words in quotes to match a phrase exactly, such as `"audio file"`.
- Matches count inside longer words, so `osc` finds `SinOsc`. Punctuation works too (`Std.mtof`, `=>`).
- **Match case** and **Regular expression** work here too. With Regular expression on, the whole search is one pattern instead of separate words.
- Results are grouped by page: the folder trail, the page title (a link), then up to three matching sections. Each shows its heading, linking straight to that section when it has an id, and a short excerpt with highlights. A button reveals the rest. A page whose title matches is tagged "title matches".
- Ranking: a heading match counts for more than a word repeated in the body, whole words rank above matches inside longer words, and title matches get a boost.

Every search has a shareable address: `/search/?q=GGen&case=1&regex=1`, or `/search/?q=audio+file&mode=site` for site pages. Links like this can go in your docs.

### How it works

The page fetches the index for the chosen mode once (the site index only when someone first switches to it), then searches it in memory with regular expressions. Example searches are turned into one regular expression with all special characters escaped. Site searches build one for each word. Matching takes from under a millisecond to about ten milliseconds for 637 examples of about 1 KB each, and 5 to 8 milliseconds on a test site with five times your amount of page text; drawing the results takes the rest.

- **Safety:** nothing runs on your server. Results are built with DOM calls, never `innerHTML`, so code or page text containing `<script>` or other markup shows as text. Searches are capped at 300 characters, 12 words, and 1,000 matches per example.
- **Regular expressions** are the visitor's own to break: a pathological pattern can slow their own tab, and no one else's. Invalid patterns show a message explaining what to do.
- **Updates:** the page asks the server whether an index changed on each visit (cheap when it hasn't), so a rebuilt index is picked up without clearing caches.
- **One failing index doesn't break the other:** if `site.json` is missing, example search still works, and the error names the file.

### Search page settings

At the top of the script in `search/index.html`:

| Setting | Default | Meaning |
|---|---|---|
| `MODES.examples.url` | `"/search/examples.json"` | Where the examples index is, as a path from the site root |
| `MODES.site.url` | `"/search/site.json"` | Where the site-content index is |
| `DEFAULT_MODE` | `"examples"` | Which mode opens first. Set `"site"` to lead with site search. Existing `?q=` links keep working either way |
| `BATCH` | 40 | Results shown at first and per "Show more results" |
| `HITS_SHOWN` | 6 | Example mode: matching lines per example before the expand button |
| `CONTEXT` | 1 | Example mode: lines of context around each match |
| `SECTIONS_SHOWN` | 3 | Site mode: matching sections per page before the expand button |
| `SNIPPET_LENGTH` | 220 | Site mode: characters in each excerpt |

Each mode's `hint` and `placeholder` text sit in the same `MODES` block. Example and page addresses both come from the indexes, so there's no setting for where the examples live.

The page also loads `/css/main.css`, like your example pages. Delete that line if it clashes with the page's own styles. The result styling is deliberately neutral (translucent grays) so it works on a light or dark site.

---

## Random example button

`random-example.html` is a demo page. The part between the `BEGIN` and `END` comments is the button; copy that block into your main page (or any page, since every address in it starts from the site root). Clicking it picks a random example from the same `examples.json` the search page uses, and opens its web page.

- **Only playable examples:** by default it picks only examples that have a web page. Set `ONLY_WITH_PAGE = false` to include examples with no page; those open the raw `.ck` file.
- **Light on visitors:** the index is downloaded only when someone points at, focuses or clicks the button, not for everyone who loads the page.
- **Doesn't repeat itself:** it remembers the last 20 picks in that browser tab and prefers examples not seen yet. It never gives the same one twice in a row. If browser storage is blocked, it still works.
- **One folder only:** add `data-folder` to a button, for example `<button type="button" data-random-example data-folder="basic">Random basic example</button>`. The value is either the folder's path from the site root (`doc/examples/basic`) or just the part inside an examples folder (`basic`, which matches that folder in every examples folder). A commented-out example is in the file, and you can have several buttons on one page.
- **If something goes wrong:** the message next to the button says what failed (the index couldn't be loaded, a different index version, or no examples in that folder), and the next click tries again.

| Setting | Default | Meaning |
|---|---|---|
| `EXAMPLES_URL` | `"/search/examples.json"` | The examples index. Keep it the same as `MODES.examples.url` in the search page |
| `ONLY_WITH_PAGE` | `true` | Only pick examples that have a web page |
| `REMEMBER` | 20 | How many recent picks to avoid repeating |

New examples appear in the button as soon as you rebuild and upload `examples.json`. For developers: the button fires a cancelable `random-example` event with `{ url, path }` just before it navigates, so a page can handle the address itself.

---

## Notes

- **Searching by folder name:** in example search, a name match looks at the whole path, so searching `chugl` finds everything in a `chugl/examples` folder. The flip side is that a search for a word in every path, such as `examples`, matches everything.
- **Order of operations:** example pages first, then links, then the indexes. The examples index checks which pages exist, and links should only point at pages that do. The site index skips generated example pages, so it doesn't matter whether they exist yet.
- **Case-insensitive file systems:** on macOS, `Foo.ck` and `foo.ck` are the same file but different URLs on most servers. Keep names consistent and lowercase.
- **File names with `+` or spaces** (`hanoi++.ck`) are fine; the scripts URL-encode them (`hanoi%2B%2B.html`).
- **Viewing raw `.ck` files:** if your server downloads `.ck` instead of showing it, serve the extension as `text/plain` so "Open .ck file" displays in the browser.
- **Compression:** optional but worthwhile; see [Turning on gzip](#turning-on-gzip).
- **Not built yet:** semantic search (finding pages by meaning rather than by the words used). The page's modes are independent, so it can arrive as a third option with its own index file, without changing the two that exist.

## Turning on gzip

A web server only compresses responses if it's configured to, and compressing is usually limited to a list of file types, so JSON is often left out. Check what you're getting with:

```
curl -s -H "Accept-Encoding: gzip" -o /dev/null -D - https://YOURSITE/search/examples.json | grep -i content-encoding
```

If nothing prints, the response isn't compressed. The index is then about 0.8 MB per visitor instead of roughly a quarter of that, which works fine; compression is an optimisation, not a requirement. To turn it on, add `application/json` to the file types your server compresses:

```nginx
# nginx (in the http or server block)
gzip on;
gzip_types application/json text/plain text/css application/javascript;
```

```apache
# Apache (mod_deflate enabled)
AddOutputFilterByType DEFLATE application/json text/plain text/html
```

If another server on the same machine already compresses, copy its compression settings. A CDN or proxy in front (such as Cloudflare) may also do it for you. Check `.ck` and `.html` files the same way: if they aren't compressed either, the same setting usually covers them.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `can't find '__main__' module` | The script name is missing from the command. `python3 SCRIPT.py FOLDER`, not `python3 FOLDER` |
| "Couldn't load /search/examples.json" (or `site.json`) | Not uploaded to that address, the address in `MODES` is wrong, or you opened the page from disk. Serve the site root (`python3 -m http.server`) |
| Random button says it couldn't load the example list | `examples.json` isn't uploaded at `EXAMPLES_URL`. Rebuild it with `build_search_index.py` and upload it |
| Example results link to missing pages | Re-run `make_example_pages.py` (for each examples folder) and then `build_search_index.py`, and upload both |
| An examples folder is missing from example search | Check the list the index builder prints. Its folder must be named `examples` (or one of your `--folder-name` values) and not be under an `--exclude`d folder |
| "the index is a different version" | `examples.json` was built by an older version of the script. Rebuild it with the current `build_search_index.py` |
| Search shows old results | Re-run `build_search_index.py` (examples) or `build_site_index.py` (pages) and upload the new file |
| Site results link to the top of a page, not the section | That heading has no `id`. Add `id="..."` to it; the build script reports how many are missing |
| Site results are full of menu or footer text | Name the element with `--skip`, for example `--skip sidebar` or `--skip outlineDiv` |
| A page is missing from site search | It's excluded (`--exclude`), marked `noindex`, a generated example page, in the search folder, or has no readable text. For markdown: a `.md` with no matching `.html` is left out (use `--md-raw`). The run prints what it left out |
| Markdown results open the page but don't jump to the section | The page doesn't create the same heading ids, or doesn't scroll to `location.hash` after displaying the markdown. Fix it in the page, or use `--no-md-anchors` |
| A page wasn't regenerated | It has no "Generated by" comment (hand-written). Use `--force` to replace it |
| "Template ... needs exactly one ..." | The template lost a placeholder. See [What the template must contain](#what-the-template-must-contain) |
| Output looks odd in an example | Check the `.ck` is UTF-8. The scripts warn when they fall back to Latin-1 |
