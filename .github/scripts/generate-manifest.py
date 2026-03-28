#!/usr/bin/env python3
"""Generate a Gentoo Manifest file for an ebuild.

Parses SRC_URI from the ebuild, downloads each source file, and writes
BLAKE2B + SHA512 checksums to a Manifest file in the same directory.

Usage: generate-manifest.py <path-to-ebuild>
"""

import hashlib
import re
import sys
import tempfile
import urllib.request
from pathlib import Path


def parse_src_uri(ebuild_path: Path) -> list[tuple[str, str]]:
    """Parse SRC_URI from an ebuild, returning [(url, filename), ...]."""
    content = ebuild_path.read_text()

    # Extract PN, PV from filename (version starts at first digit after hyphen)
    match = re.match(r"^(.+?)-(\d.*)$", ebuild_path.stem)
    if not match:
        raise ValueError(f"Cannot parse PN-PV from {ebuild_path.stem}")
    pn, pv = match.groups()
    p = f"{pn}-{pv}"

    # Extract SRC_URI="..." block (single or multi-line)
    uri_match = re.search(r'SRC_URI="(.*?)"', content, re.DOTALL)
    if not uri_match:
        raise ValueError(f"No SRC_URI found in {ebuild_path}")

    raw = uri_match.group(1)

    # Strip USE conditionals: amd64? ( ... )
    raw = re.sub(r"\w+\?\s*\(", "", raw)
    raw = raw.replace(")", "")

    # Expand Portage variables
    raw = raw.replace("${PV}", pv).replace("${PN}", pn).replace("${P}", p)

    # Parse URL -> filename pairs
    tokens = raw.split()
    results = []
    i = 0
    while i < len(tokens):
        if tokens[i].startswith(("http://", "https://")):
            url = tokens[i]
            if i + 2 < len(tokens) and tokens[i + 1] == "->":
                filename = tokens[i + 2]
                i += 3
            else:
                filename = url.rsplit("/", 1)[-1]
                i += 1
            results.append((url, filename))
        else:
            i += 1

    return results


def compute_checksums(filepath: Path) -> tuple[int, str, str]:
    """Return (size, blake2b_hex, sha512_hex) for a file."""
    blake2b = hashlib.blake2b()
    sha512 = hashlib.sha512()

    with open(filepath, "rb") as f:
        while chunk := f.read(65536):
            blake2b.update(chunk)
            sha512.update(chunk)

    return filepath.stat().st_size, blake2b.hexdigest(), sha512.hexdigest()


def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <ebuild-path>", file=sys.stderr)
        sys.exit(1)

    ebuild_path = Path(sys.argv[1])
    if not ebuild_path.exists():
        print(f"Error: {ebuild_path} not found", file=sys.stderr)
        sys.exit(1)

    sources = parse_src_uri(ebuild_path)
    manifest_lines = []

    opener = urllib.request.build_opener()
    opener.addheaders = [("User-Agent", "Wget/1.21")]

    for url, filename in sources:
        print(f"Downloading {filename}...", file=sys.stderr)
        with tempfile.NamedTemporaryFile(delete=False) as tmp:
            with opener.open(url) as resp:
                tmp.write(resp.read())
            tmp_path = Path(tmp.name)

        size, blake2b, sha512 = compute_checksums(tmp_path)
        manifest_lines.append(
            f"DIST {filename} {size} BLAKE2B {blake2b} SHA512 {sha512}"
        )
        tmp_path.unlink()

    manifest_path = ebuild_path.parent / "Manifest"
    manifest_path.write_text("\n".join(manifest_lines) + "\n")
    print(f"Generated {manifest_path}", file=sys.stderr)


if __name__ == "__main__":
    main()
