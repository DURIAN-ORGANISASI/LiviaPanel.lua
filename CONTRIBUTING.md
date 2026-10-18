# Contributing to Livia Panel

Thank you for helping improve the project. Small, focused pull requests are easiest to review.

## Before opening a pull request

1. Describe the change and the problem it solves.
2. Keep the Indonesian and English READMEs consistent when user-facing behavior or instructions change.
3. When changing the SVG artwork, update `docs/generate-images.py` and regenerate the files instead of editing generated images by hand.
4. Do not add personal data, account credentials, access tokens, or private game information.

## Run documentation checks

The repository currently has no automated Roblox runtime test harness. Automated checks validate local documentation links, parse SVG/XML, reject illustrations with missing visible text, and regenerate all SVG assets in a temporary directory to ensure the committed artwork matches its source generator. They do not prove that a script works in every Roblox experience.

Requirements: Python 3.9 or newer, using only the standard library.

```bash
python3 scripts/check_docs.py
```

To regenerate the bilingual documentation artwork:

```bash
python3 docs/generate-images.py
python3 scripts/check_docs.py
git diff --check
```

Review generated changes before committing them. Do not commit unrelated changes or modify the existing MIT license without a deliberate licensing decision.

## Pull request checklist

- [ ] The change has a clear purpose and summary.
- [ ] Documentation in both languages is updated where needed.
- [ ] `python3 scripts/check_docs.py` passes.
- [ ] Generated artwork is reproducible from its generator.
- [ ] No credentials or personal information are included.
- [ ] Any new third-party source, asset, or dependency is documented in [`docs/SOURCES.md`](docs/SOURCES.md) with its license or attribution requirements.

By contributing, you confirm that you have the right to submit the changes under this repository's MIT license.
