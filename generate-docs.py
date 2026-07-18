#!/usr/bin/env python3
"""
generate-docs.py

Scans every *.sh file in the repository for a documentation metadata block:

    #!/bin/bash
    # ---DOC-START---
    # summary: ...
    # description: |
    #   ...
    # sudo: true|false
    # interactive: true|false
    # idempotent: true|false|mostly
    # ---DOC-END---

...and renders a single static HTML page (docs/index.html) with a summary
table and a detailed, per-directory breakdown of every script.

Usage:
    ./generate-docs.py                 # scan repo root, write docs/index.html
    ./generate-docs.py --strict        # exit non-zero if any *.sh has no block
    ./generate-docs.py --root DIR      # scan a different repo root
    ./generate-docs.py --out FILE      # write to a different output path

No third-party dependencies -- standard library only, so it runs the same way
locally and in CI (see .github/workflows).
"""

from __future__ import annotations

import argparse
import datetime
import html
import os
import re
import sys
from dataclasses import dataclass, field

DOC_START = "# ---DOC-START---"
DOC_END = "# ---DOC-END---"

# Directories that are never part of the documented toolkit (i.e. never scanned for scripts).
EXCLUDED_DIRS = {".git", "docs", "node_modules", ".github"}

# Directories/files excluded from the *repository structure tree* (junk only --
# unlike EXCLUDED_DIRS above, the tree does want to show docs/ and .github/).
TREE_EXCLUDE = {".git", "__pycache__", "node_modules", ".DS_Store"}

# One-line purpose comments for top-level (and a couple of second-level) directories,
# shown next to the directory name in the generated repository structure tree.
# This is the only hand-maintained piece of the tree -- everything else (which files
# and subdirectories actually exist) is discovered by walking the filesystem.
DIR_PURPOSE = {
    "server": "Server deployment, monitoring, and maintenance",
    "network": "Read-only network diagnostics and status checks",
    "workflows": "Multi-step orchestrators and their config",
    "maintenance": "System utilities and one-off admin tasks",
    "apt": "Individual apt package installers",
    "apt/cli": "CLI tools",
    "apt/gui": "GUI apps",
    "flatpak": "Flatpak app installers",
    "pipx": "pipx-based tool installers",
    "lsp": "Language server installations",
    "utilities": "General-purpose standalone tools",
    "yt-dlp": "Video and audio download helpers",
    "qol": "Bash quality-of-life and terminal customization",
    "showcase": "Terminal portfolio and visual scripts",
    "nvidia": "NVIDIA GPU driver installation",
    "docs": "Generated documentation + metadata guidelines",
    ".github": "CI workflows",
}

TOP_KEY_RE = re.compile(r"^# ([a-zA-Z_]+): ?(.*)$")


def slugify(text: str) -> str:
    return re.sub(r"[^a-zA-Z0-9]+", "-", text).strip("-").lower()


def dir_anchor(directory: str) -> str:
    slug = slugify(directory)
    return f"dir-{slug}" if slug else "dir-root"


@dataclass
class ScriptDoc:
    relpath: str  # e.g. "server/deploy-nginx.sh"
    summary: str = ""
    description: str = ""
    sudo: bool = False
    interactive: bool = False
    idempotent: str = "false"  # "true" | "false" | "mostly"

    @property
    def directory(self) -> str:
        d = os.path.dirname(self.relpath)
        return d if d else "."

    @property
    def filename(self) -> str:
        return os.path.basename(self.relpath)

    @property
    def anchor(self) -> str:
        return "script-" + re.sub(r"[^a-zA-Z0-9]+", "-", self.relpath).strip("-").lower()


def find_scripts(root: str) -> list[str]:
    found = []
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in EXCLUDED_DIRS and not d.startswith(".")]
        for fn in filenames:
            if fn.endswith(".sh"):
                found.append(os.path.relpath(os.path.join(dirpath, fn), root))
    return sorted(found)


def parse_bool(value: str, default: bool = False) -> bool:
    return value.strip().lower() == "true"


def parse_doc_block(path: str, relpath: str) -> ScriptDoc | None:
    with open(path, "r", encoding="utf-8", errors="replace") as f:
        text = f.read()

    start = text.find(DOC_START)
    end = text.find(DOC_END)
    if start == -1 or end == -1 or end < start:
        return None

    block = text[start + len(DOC_START):end].split("\n")

    doc = ScriptDoc(relpath=relpath)
    in_description = False
    desc_lines: list[str] = []

    for raw_line in block:
        top_match = TOP_KEY_RE.match(raw_line)
        is_top_level = top_match is not None and not raw_line.startswith("#   ")

        if is_top_level:
            if in_description:
                doc.description = "\n".join(desc_lines).strip("\n")
                in_description = False
                desc_lines = []

            key, value = top_match.group(1), top_match.group(2)
            value = value.strip()

            if key == "summary":
                doc.summary = value
            elif key == "description":
                if value == "|":
                    in_description = True
                    desc_lines = []
                else:
                    doc.description = value
            elif key == "sudo":
                doc.sudo = parse_bool(value)
            elif key == "interactive":
                doc.interactive = parse_bool(value)
            elif key == "idempotent":
                doc.idempotent = value.lower() if value.lower() in ("true", "false", "mostly") else "false"
            continue

        if in_description:
            if raw_line == "#":
                desc_lines.append("")
            elif raw_line.startswith("#   "):
                desc_lines.append(raw_line[4:])
            elif raw_line.startswith("# "):
                desc_lines.append(raw_line[2:])
            # blank lines between markers are ignored otherwise

    if in_description:
        doc.description = "\n".join(desc_lines).strip("\n")

    return doc


# ---------------------------------------------------------------------------
# Minimal markdown -> HTML (only the subset used in DOC-START/DOC-END blocks:
# paragraphs, "- " bullet lists, "> " blockquotes, **bold**, `code`, [text](url))
# ---------------------------------------------------------------------------

def render_inline(text: str) -> str:
    escaped = html.escape(text, quote=False)

    # Protect inline code spans first so bold/link patterns don't reach inside them.
    code_spans: list[str] = []

    def stash_code(m: re.Match) -> str:
        code_spans.append(m.group(1))
        return f"\x00CODE{len(code_spans) - 1}\x00"

    escaped = re.sub(r"`([^`]+)`", stash_code, escaped)
    escaped = re.sub(r"\[([^\]]+)\]\(([^)]+)\)", r'<a href="\2">\1</a>', escaped)
    escaped = re.sub(r"\*\*([^*]+)\*\*", r"<strong>\1</strong>", escaped)

    def restore_code(m: re.Match) -> str:
        idx = int(m.group(1))
        return f"<code>{code_spans[idx]}</code>"

    escaped = re.sub(r"\x00CODE(\d+)\x00", restore_code, escaped)
    return escaped


def render_description(md: str) -> str:
    if not md.strip():
        return ""

    lines = md.split("\n")
    blocks: list[str] = []
    para: list[str] = []
    list_items: list[str] = []
    quote_lines: list[str] = []

    def flush_para():
        if para:
            blocks.append(f"<p>{render_inline(' '.join(para))}</p>")
            para.clear()

    def flush_list():
        if list_items:
            items = "".join(f"<li>{render_inline(it)}</li>" for it in list_items)
            blocks.append(f"<ul>{items}</ul>")
            list_items.clear()

    def flush_quote():
        if quote_lines:
            inner = "<br>".join(render_inline(q) if q else "" for q in quote_lines)
            blocks.append(f"<blockquote>{inner}</blockquote>")
            quote_lines.clear()

    for line in lines:
        stripped = line.strip()
        if stripped.startswith("- "):
            flush_para()
            flush_quote()
            list_items.append(stripped[2:])
        elif stripped.startswith(">"):
            flush_para()
            flush_list()
            quote_lines.append(stripped[1:].strip())
        elif stripped == "":
            flush_para()
            flush_list()
            flush_quote()
        else:
            flush_list()
            flush_quote()
            para.append(stripped)

    flush_para()
    flush_list()
    flush_quote()

    return "\n".join(blocks)


# ---------------------------------------------------------------------------
# Repository structure tree (fully discovered from the filesystem)
# ---------------------------------------------------------------------------

def _list_dir(path: str) -> tuple[list[str], list[str]]:
    dirs, files = [], []
    for entry in os.listdir(path):
        if entry in TREE_EXCLUDE or entry == ".git":
            continue
        full = os.path.join(path, entry)
        (dirs if os.path.isdir(full) else files).append(entry)
    return sorted(dirs), sorted(files)


# Repo name is fixed rather than derived from the local checkout's folder name
# (which varies -- e.g. a CI runner's workspace dir), so the tree always reads
# "shell-toolkit/" regardless of what the containing directory happens to be called.
REPO_NAME = "shell-toolkit"


def build_tree_text(root: str) -> str:
    lines = [f"{REPO_NAME}/"]

    def recurse(path: str, prefix: str, rel: str):
        dirs, files = _list_dir(path)
        entries = [(d, True) for d in dirs] + [(f, False) for f in files]
        for i, (name, is_dir) in enumerate(entries):
            is_last = i == len(entries) - 1
            connector = "\u2514\u2500\u2500 " if is_last else "\u251c\u2500\u2500 "
            display = name + "/" if is_dir else name
            child_rel = f"{rel}/{name}" if rel else name
            line = prefix + connector + display
            purpose = DIR_PURPOSE.get(child_rel) if is_dir else None
            if purpose:
                pad = max(1, 42 - len(line))
                line += " " * pad + f"# {purpose}"
            lines.append(line)
            if is_dir:
                extension = "    " if is_last else "\u2502   "
                recurse(os.path.join(path, name), prefix + extension, child_rel)

    recurse(root, "", "")
    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Aggregate stats over parsed docs
# ---------------------------------------------------------------------------

def compute_stats(docs: list[ScriptDoc]) -> dict:
    total = len(docs)
    sudo_count = sum(1 for d in docs if d.sudo)
    interactive_count = sum(1 for d in docs if d.interactive)
    idempotent_counts = {"true": 0, "mostly": 0, "false": 0}
    for d in docs:
        idempotent_counts[d.idempotent] = idempotent_counts.get(d.idempotent, 0) + 1
    by_dir: dict[str, int] = {}
    for d in docs:
        by_dir[d.directory] = by_dir.get(d.directory, 0) + 1
    return {
        "total": total,
        "directories": len(by_dir),
        "by_dir": by_dir,
        "sudo_count": sudo_count,
        "interactive_count": interactive_count,
        "idempotent_counts": idempotent_counts,
    }


# ---------------------------------------------------------------------------
# HTML rendering
# ---------------------------------------------------------------------------

CSS = """
:root {
  color-scheme: light;
}
* { box-sizing: border-box; }
body {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
  color: #1f2328;
  background: #ffffff;
  max-width: 1320px;
  margin: 0 auto;
  padding: 32px 24px 80px;
  line-height: 1.5;
}
h1, h2, h3 { line-height: 1.25; }
h1 {
  font-size: 2em;
  border-bottom: 1px solid #d1d9e0;
  padding-bottom: .3em;
}
h2 {
  font-size: 1.5em;
  border-bottom: 1px solid #d1d9e0;
  padding-bottom: .3em;
  margin-top: 2em;
}
h3 {
  font-size: 1.15em;
  margin-top: 1.6em;
  font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
}
p { margin: .6em 0; }
a { color: #0969da; text-decoration: none; }
a:hover { text-decoration: underline; }
code {
  font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
  background: #f6f8fa;
  padding: .15em .4em;
  border-radius: 6px;
  font-size: .9em;
}
pre {
  background: #f6f8fa;
  border-radius: 6px;
  padding: 16px;
  overflow-x: auto;
}
pre code {
  background: none;
  padding: 0;
  font-size: .85em;
  white-space: pre;
}
blockquote {
  margin: .8em 0;
  padding: 0 1em;
  color: #59636e;
  border-left: .25em solid #d1d9e0;
}
ul { padding-left: 1.4em; }
li { margin: .2em 0; }
table {
  border-collapse: collapse;
  width: 100%;
  margin: 1em 0;
  font-size: .95em;
}
th, td {
  border: 1px solid #d1d9e0;
  padding: 6px 10px;
  text-align: left;
  vertical-align: top;
}
th { background: #f6f8fa; }
tr:nth-child(2n) { background: #f6f8fa; }
.badge { font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; }
.meta-row { margin: .8em 0; font-size: .95em; color: #59636e; }
.meta-row span { margin-right: 1.4em; }
.script-card {
  border: 1px solid #d1d9e0;
  border-radius: 6px;
  padding: 16px 20px;
  margin: 1em 0 1.6em;
}
.dir-tag {
  font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
  color: #59636e;
  font-size: .85em;
}
.generated-note {
  color: #59636e;
  font-size: .9em;
  margin-top: 3em;
  border-top: 1px solid #d1d9e0;
  padding-top: 1em;
}

/* Two-column layout: main content + sticky right-hand table of contents */
.layout {
  display: flex;
  align-items: flex-start;
  gap: 40px;
}
.content {
  flex: 1 1 auto;
  min-width: 0;
}
.toc {
  flex: 0 0 240px;
  position: sticky;
  top: 20px;
  max-height: calc(100vh - 40px);
  overflow-y: auto;
  font-size: .85em;
  border-left: 1px solid #d1d9e0;
  padding-left: 16px;
}
.toc-title {
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: .04em;
  font-size: .78em;
  color: #59636e;
  margin-bottom: .6em;
}
.toc ul {
  list-style: none;
  padding-left: 0;
  margin: 0;
}
.toc li { margin: 0; }
.toc a {
  display: block;
  color: #59636e;
  padding: 3px 0 3px 10px;
  border-left: 2px solid transparent;
}
.toc a:hover {
  color: #0969da;
  text-decoration: none;
}
.toc a.active {
  color: #0969da;
  border-left-color: #0969da;
  font-weight: 600;
}
.toc .toc-divider {
  margin-top: 1em;
  padding-top: .6em;
  border-top: 1px solid #d1d9e0;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: .04em;
  font-size: .78em;
  color: #59636e;
}
.toc .toc-count {
  color: #8c959f;
  font-size: .9em;
}
.toc-back-to-top {
  display: inline-block;
  margin-top: 1em;
}

.filter-box {
  margin: 1em 0;
}
.filter-box input {
  width: 100%;
  padding: 8px 12px;
  font-size: .95em;
  border: 1px solid #d1d9e0;
  border-radius: 6px;
  font-family: inherit;
}
.filter-box input:focus {
  outline: none;
  border-color: #0969da;
}
.filter-hint {
  font-size: .82em;
  color: #59636e;
  margin-top: .3em;
}
tr.filtered-out { display: none; }

@media (max-width: 900px) {
  .layout { flex-direction: column-reverse; gap: 0; }
  .toc {
    position: static;
    max-height: none;
    width: 100%;
    border-left: none;
    border-top: 1px solid #d1d9e0;
    padding-left: 0;
    padding-top: 16px;
    margin-bottom: 1em;
  }
}
"""

IDEMPOTENT_BADGE = {"true": "\u2705", "false": "\u274c", "mostly": "\u26a0\ufe0f"}
BOOL_BADGE = {True: "\u2705", False: "\u274c"}


def build_summary_table(docs: list[ScriptDoc]) -> str:
    rows = []
    for d in docs:
        search_blob = html.escape(f"{d.directory} {d.filename} {d.summary}".lower(), quote=True)
        rows.append(
            f'<tr data-search="{search_blob}">'
            f'<td class="dir-tag">{html.escape(d.directory)}</td>'
            f'<td><a href="#{d.anchor}"><code>{html.escape(d.filename)}</code></a></td>'
            f"<td>{render_inline(d.summary)}</td>"
            f'<td class="badge">{BOOL_BADGE[d.sudo]}</td>'
            f'<td class="badge">{BOOL_BADGE[d.interactive]}</td>'
            f'<td class="badge">{IDEMPOTENT_BADGE.get(d.idempotent, "\u274c")}</td>'
            "</tr>"
        )
    return (
        '<table id="all-scripts-table">\n<thead><tr>'
        "<th>Directory</th><th>Script</th><th>Summary</th>"
        "<th>Sudo</th><th>Interactive</th><th>Idempotent</th>"
        "</tr></thead>\n<tbody>\n" + "\n".join(rows) + "\n</tbody>\n</table>"
    )


def build_script_card(d: ScriptDoc) -> str:
    desc_html = render_description(d.description)
    return f"""<div class="script-card" id="{d.anchor}">
<h3><code>{html.escape(d.relpath)}</code></h3>
<div class="meta-row">
<span class="badge">Sudo: {BOOL_BADGE[d.sudo]}</span>
<span class="badge">Interactive: {BOOL_BADGE[d.interactive]}</span>
<span class="badge">Idempotent: {IDEMPOTENT_BADGE.get(d.idempotent, "\u274c")} ({html.escape(d.idempotent)})</span>
</div>
{desc_html}
</div>"""


def build_stats_block(stats: dict) -> str:
    idem = stats["idempotent_counts"]
    dir_rows = "".join(
        f"<tr><td class='dir-tag'>{html.escape(d)}</td><td>{n}</td></tr>"
        for d, n in sorted(stats["by_dir"].items())
    )
    return f"""<h2 id="at-a-glance">At a Glance</h2>
<table>
<thead><tr><th>Metric</th><th>Value</th></tr></thead>
<tbody>
<tr><td>Total scripts</td><td>{stats['total']}</td></tr>
<tr><td>Directories</td><td>{stats['directories']}</td></tr>
<tr><td>Require root / sudo</td><td>{stats['sudo_count']} / {stats['total']}</td></tr>
<tr><td>Interactive</td><td>{stats['interactive_count']} / {stats['total']}</td></tr>
<tr><td>Idempotent (always / mostly / no)</td>
    <td>{idem.get('true', 0)} / {idem.get('mostly', 0)} / {idem.get('false', 0)}</td></tr>
</tbody>
</table>
<table>
<thead><tr><th>Directory</th><th>Scripts</th></tr></thead>
<tbody>
{dir_rows}
</tbody>
</table>"""


def build_toc(by_dir: dict[str, list[ScriptDoc]]) -> str:
    top_links = [
        '<li><a href="#at-a-glance">At a Glance</a></li>',
        '<li><a href="#repository-structure">Repository Structure</a></li>',
        '<li><a href="#all-scripts">All Scripts</a></li>',
    ]
    dir_links = [
        f'<li><a href="#{dir_anchor(directory)}">{html.escape(directory)}/'
        f'<span class="toc-count"> ({len(by_dir[directory])})</span></a></li>'
        for directory in sorted(by_dir)
    ]
    return f"""<nav class="toc" id="toc" aria-label="On this page">
<div class="toc-title">On this page</div>
<ul>
{''.join(top_links)}
<li class="toc-divider">Directories</li>
{''.join(dir_links)}
</ul>
<a class="toc-back-to-top" href="#top">&uarr; Back to top</a>
</nav>"""


def build_html(docs: list[ScriptDoc], repo_root: str) -> str:
    by_dir: dict[str, list[ScriptDoc]] = {}
    for d in docs:
        by_dir.setdefault(d.directory, []).append(d)

    sections = []
    for directory in sorted(by_dir):
        cards = "\n".join(build_script_card(d) for d in by_dir[directory])
        sections.append(
            f'<h2 id="{dir_anchor(directory)}"><code>{html.escape(directory)}/</code></h2>\n{cards}'
        )

    generated_at = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    stats = compute_stats(docs)
    tree_text = build_tree_text(repo_root)

    return f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>shell-toolkit — Script Documentation</title>
<style>{CSS}</style>
</head>
<body>
<a id="top"></a>
<h1>shell-toolkit — Script Documentation</h1>
<p>Auto-generated from the <code># ---DOC-START---</code> / <code># ---DOC-END---</code> metadata
block at the top of every script. Do not edit this file by hand — edit the metadata in the
scripts and re-run <code>generate-docs.py</code> instead.</p>

<div class="layout">
<div class="content">

{build_stats_block(stats)}

<h2 id="repository-structure">Repository Structure</h2>
<pre><code>{html.escape(tree_text)}</code></pre>

<h2 id="all-scripts">All Scripts</h2>
<div class="filter-box">
<input type="text" id="script-filter" placeholder="Filter scripts by name, summary, or directory…" autocomplete="off">
<div class="filter-hint" id="filter-hint"></div>
</div>
{build_summary_table(docs)}

{''.join(sections)}

<p class="generated-note">Generated by <code>generate-docs.py</code> on {generated_at} &middot;
{len(docs)} scripts documented.</p>

</div>
{build_toc(by_dir)}
</div>

<script>
(function() {{
  // --- Live filter for the "All Scripts" summary table ---
  var input = document.getElementById('script-filter');
  var hint = document.getElementById('filter-hint');
  var rows = Array.prototype.slice.call(
    document.querySelectorAll('#all-scripts-table tbody tr')
  );
  if (input) {{
    input.addEventListener('input', function() {{
      var q = input.value.trim().toLowerCase();
      var shown = 0;
      rows.forEach(function(row) {{
        var match = !q || (row.getAttribute('data-search') || '').indexOf(q) !== -1;
        row.classList.toggle('filtered-out', !match);
        if (match) shown++;
      }});
      hint.textContent = q ? (shown + ' of ' + rows.length + ' scripts match') : '';
    }});
  }}

  // --- Scrollspy: highlight the current section in the TOC while scrolling ---
  var tocLinks = Array.prototype.slice.call(document.querySelectorAll('.toc a[href^="#"]'));
  var targets = tocLinks
    .map(function(a) {{
      var id = a.getAttribute('href').slice(1);
      var el = document.getElementById(id);
      return el ? {{ link: a, el: el }} : null;
    }})
    .filter(Boolean);

  function onScroll() {{
    var pos = window.scrollY + 110;
    var current = null;
    targets.forEach(function(t) {{
      if (t.el.offsetTop <= pos) current = t;
    }});
    tocLinks.forEach(function(a) {{ a.classList.remove('active'); }});
    if (current) current.link.classList.add('active');
  }}
  window.addEventListener('scroll', onScroll, {{ passive: true }});
  onScroll();
}})();
</script>
</body>
</html>
"""


# ---------------------------------------------------------------------------

def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--root", default=os.path.dirname(os.path.abspath(__file__)),
                         help="Repository root to scan (default: this script's directory)")
    parser.add_argument("--out", default=None,
                         help="Output HTML path (default: <root>/docs/index.html)")
    parser.add_argument("--strict", action="store_true",
                         help="Exit with non-zero status if any .sh file is missing a DOC block")
    args = parser.parse_args()

    root = os.path.abspath(args.root)
    out_path = args.out or os.path.join(root, "docs", "index.html")

    script_paths = find_scripts(root)
    docs: list[ScriptDoc] = []
    undocumented: list[str] = []

    for relpath in script_paths:
        full = os.path.join(root, relpath)
        doc = parse_doc_block(full, relpath)
        if doc is None:
            undocumented.append(relpath)
            continue
        docs.append(doc)

    if undocumented:
        print(f"[!] {len(undocumented)} script(s) missing a DOC-START/DOC-END block:", file=sys.stderr)
        for u in undocumented:
            print(f"    - {u}", file=sys.stderr)

    docs.sort(key=lambda d: d.relpath)

    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(build_html(docs, root))

    print(f"[+] Wrote {out_path} ({len(docs)} scripts documented)")

    if args.strict and undocumented:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
