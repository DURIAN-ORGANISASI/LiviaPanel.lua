#!/usr/bin/env python3
"""Validate repository Markdown references and the XML syntax of documentation SVGs."""
from __future__ import annotations

import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parents[1]
MARKDOWN_LINK_RE = re.compile(r"!?\\[[^\\]]*\\]\\(\\s*(?:<([^>]+)>|([^\\s)]+))")
HTML_SRC_RE = re.compile(r"<(?:img|source)\\b[^>]*?\\bsrc=[\\"']([^\\"']+)[\\"']", re.IGNORECASE)


def markdown_files() -> list[Path]:
    files = set(ROOT.glob("*.md"))
    docs = ROOT / "docs"
    if docs.exists():
        files.update(docs.rglob("*.md"))
    return sorted(files)


def referenced_local_paths(markdown_path: Path) -> list[tuple[str, str]]:
    source = markdown_path.read_text(encoding="utf-8")
    links = []
    for match in MARKDOWN_LINK_RE.finditer(source):
        links.append((match.group(1) or match.group(2), "Markdown link"))
    for match in HTML_SRC_RE.finditer(source):
        links.append((match.group(1), "HTML src"))
    return links


def check_local_references() -> tuple[int, list[str]]:
    checked = 0
    errors: list[str] = []
    for markdown_path in markdown_files():
        for target, kind in referenced_local_paths(markdown_path):
            parsed = urlsplit(target)
            if parsed.scheme or parsed.netloc or target.startswith("//"):
                continue
            if not parsed.path:
                continue

            raw_path = unquote(parsed.path)
            candidate = (ROOT / raw_path.lstrip("/")) if raw_path.startswith("/") else (markdown_path.parent / raw_path)
            candidate = candidate.resolve()
            checked += 1
            if not candidate.is_relative_to(ROOT):
                errors.append(f"{markdown_path.relative_to(ROOT)}: {kind} escapes repository: {target}")
            elif not candidate.exists():
                errors.append(f"{markdown_path.relative_to(ROOT)}: broken {kind}: {target}")
    return checked, errors


def check_svg_files() -> tuple[int, list[str]]:
    svg_files = sorted((ROOT / "docs").rglob("*.svg"))
    errors: list[str] = []
    for svg_path in svg_files:
        try:
            root = ET.parse(svg_path).getroot()
            if root.tag != "{http://www.w3.org/2000/svg}svg":
                errors.append(f"{svg_path.relative_to(ROOT)}: root element is not an SVG element")
        except (ET.ParseError, OSError) as exc:
            errors.append(f"{svg_path.relative_to(ROOT)}: invalid SVG/XML: {exc}")
    return len(svg_files), errors


def main() -> int:
    link_count, link_errors = check_local_references()
    svg_count, svg_errors = check_svg_files()
    errors = link_errors + svg_errors

    print(f"Checked {link_count} local Markdown/HTML references.")
    print(f"Parsed {svg_count} SVG files.")
    if errors:
        print("Documentation checks failed:", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1
    print("Documentation checks passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
