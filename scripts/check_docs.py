#!/usr/bin/env python3
"""Validate repository links, SVG structure, and generated-artwork consistency."""
from __future__ import annotations

import re
import shutil
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET
from pathlib import Path
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parents[1]
MARKDOWN_LINK_RE = re.compile(r"!?\\[[^\\]]*\\]\\(\\s*(?:<([^>]+)>|([^\\s)]+))")
HTML_SRC_RE = re.compile(r"""<(?:img|source)\\b[^>]*?\\bsrc=["']([^"']+)["']""", re.IGNORECASE)
SVG_NS = "{http://www.w3.org/2000/svg}"


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
            if root.tag != f"{SVG_NS}svg":
                errors.append(f"{svg_path.relative_to(ROOT)}: root element is not an SVG element")
                continue

            # Valid XML can still be visually blank. The brand mark is intentionally text-free.
            if svg_path != ROOT / "docs" / "brand.svg":
                text_count = len(root.findall(f".//{SVG_NS}text"))
                if text_count < 8:
                    errors.append(
                        f"{svg_path.relative_to(ROOT)}: illustration appears incomplete "
                        f"({text_count} text elements; expected at least 8)"
                    )
        except (ET.ParseError, OSError) as exc:
            errors.append(f"{svg_path.relative_to(ROOT)}: invalid SVG/XML: {exc}")
    return len(svg_files), errors


def check_generated_artwork() -> tuple[int, list[str]]:
    """Regenerate in a temporary copy and ensure committed SVGs match their source."""
    generator = ROOT / "docs" / "generate-images.py"
    if not generator.is_file():
        return 0, ["docs/generate-images.py: generator is missing"]

    errors: list[str] = []
    with tempfile.TemporaryDirectory(prefix="livia-docs-check-") as temp_dir:
        temp_docs = Path(temp_dir) / "docs"
        temp_docs.mkdir(parents=True)
        temp_generator = temp_docs / "generate-images.py"
        shutil.copy2(generator, temp_generator)

        try:
            completed = subprocess.run(
                [sys.executable, str(temp_generator)],
                capture_output=True,
                text=True,
                timeout=60,
                check=False,
            )
        except (OSError, subprocess.TimeoutExpired) as exc:
            return 0, [f"Could not run artwork generator: {exc}"]

        if completed.returncode != 0:
            detail = completed.stderr.strip() or completed.stdout.strip() or "unknown error"
            return 0, [f"Artwork generator failed: {detail}"]

        generated_files = sorted(path for path in temp_docs.rglob("*.svg") if path.is_file())
        committed_files = sorted(path for path in (ROOT / "docs").rglob("*.svg") if path.is_file())
        generated_rel = {path.relative_to(temp_docs) for path in generated_files}
        committed_rel = {path.relative_to(ROOT / "docs") for path in committed_files}

        for missing in sorted(generated_rel - committed_rel):
            errors.append(f"docs/{missing.as_posix()}: generated artwork is missing from the repository")
        for extra in sorted(committed_rel - generated_rel):
            errors.append(f"docs/{extra.as_posix()}: SVG is not produced by the artwork generator")

        compared = 0
        for relative in sorted(generated_rel & committed_rel):
            expected = (temp_docs / relative).read_bytes()
            actual = (ROOT / "docs" / relative).read_bytes()
            compared += 1
            if actual != expected:
                errors.append(
                    f"docs/{relative.as_posix()}: generated artwork is out of sync; "
                    "run python3 docs/generate-images.py and commit the result"
                )
    return compared, errors


def main() -> int:
    link_count, link_errors = check_local_references()
    svg_count, svg_errors = check_svg_files()
    artwork_count, artwork_errors = check_generated_artwork()
    errors = link_errors + svg_errors + artwork_errors

    print(f"Checked {link_count} local Markdown/HTML references.")
    print(f"Parsed {svg_count} SVG files for XML validity and non-empty illustration content.")
    print(f"Compared {artwork_count} generated SVG files with docs/generate-images.py.")
    if errors:
        print("Documentation checks failed:", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1
    print("Documentation checks passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
